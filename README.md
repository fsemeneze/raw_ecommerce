# Portfolio E-commerce (Olist)

Projeto de Analytics Engineering usando dbt Core + Google BigQuery com o dataset público [Olist Brazilian E-commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Arquitetura

```mermaid
flowchart TB
    subgraph Origem["📦 Origem (Kaggle)"]
        K1["olist_orders_dataset.csv"]
        K2["olist_order_items_dataset.csv"]
        K3["olist_customers_dataset.csv"]
        K4["olist_products_dataset.csv"]
        K5["olist_order_payments_dataset.csv"]
        K6["olist_order_reviews_dataset.csv"]
        K7["olist_sellers_dataset.csv"]
        K8["olist_geolocation_dataset.csv"]
    end

    subgraph Raw["🗄️ Camada Raw — BigQuery (raw_ecommerce)"]
        R1["orders ─ 99.441 linhas"]
        R2["order_items ─ 112.650 linhas"]
        R3["customers ─ 99.441 linhas"]
        R4["products ─ 32.951 linhas"]
        R5["payments ─ 103.886 linhas"]
        R6["reviews ─ 99.224 linhas"]
        R7["sellers ─ 3.095 linhas"]
        R8["geolocation ─ 1.000.163 linhas"]
    end

    subgraph Staging["🔧 Camada Staging — dbt (views em raw_ecommerce_staging)"]
        S1["stg_orders<br/>CASTs, renomeio, timestamps"]
        S2["stg_order_items<br/>preço/frete → NUMERIC"]
        S3["stg_customers<br/>INITCAP cidade, UPPER estado"]
        S4["stg_products<br/>dimensões → FLOAT64"]
        S5["stg_payments<br/>tipos e parcelas"]
        S6["stg_reviews<br/>notas e timestamps"]
        S7["stg_sellers<br/>cidade/estado padronizados"]
        S8["stg_geolocation<br/>coordenadas e localização"]
    end

    subgraph Marts["🏗️ Camada Marts — dbt (tables em raw_ecommerce_marts)"]
        D1["dim_customers<br/>surrogate key, lifetime orders"]
        D2["dim_products<br/>peso_kg, volume_cm³"]
        D3["dim_sellers<br/>lifetime revenue, produtos"]
        D4["dim_geolocation<br/>lat/lng médios por CEP"]
        F1["fct_orders<br/>fato central: ciclo + entrega + finanças"]
        F2["fct_payments<br/>valores por tipo de pagamento"]
        F3["fct_reviews<br/>notas, estrelas, tempo resposta"]
    end

    subgraph BI["📊 Camada BI — dbt (views em raw_ecommerce_marts)"]
        V1["bi_orders<br/>1 linha = 1 pedido<br/>cliente + entrega + review"]
        V2["bi_order_items<br/>1 linha = 1 item<br/>produto + vendedor + frete"]
    end

    subgraph Dashboard["📈 Looker Studio"]
        L1["Página 1: Visão Geral<br/>Receita, pedidos, ticket, % on-time"]
        L2["Página 2: Produtos<br/>Categorias, top 20, itens vendidos"]
        L3["Página 3: Logística<br/>On-time vs late, mapa de atraso"]
        L4["Página 4: Clientes<br/>Notas, distribuição geográfica, LTV"]
    end

    K1 --> R1
    K2 --> R2
    K3 --> R3
    K4 --> R4
    K5 --> R5
    K6 --> R6
    K7 --> R7
    K8 --> R8

    R1 --> S1
    R2 --> S2
    R3 --> S3
    R4 --> S4
    R5 --> S5
    R6 --> S6
    R7 --> S7
    R8 --> S8

    S1 --> F1
    S2 --> F1
    S3 --> D1
    S4 --> D2
    S5 --> F2
    S6 --> F3
    S7 --> D3
    S8 --> D4

    D1 --> F1
    D2 -.-> V2
    D3 -.-> V2
    F1 --> V1
    F1 --> V2
    F2 --> V1
    F3 --> V1
    D1 --> V1

    V1 --> L1
    V2 --> L2
    V1 --> L3
    V1 --> L4
```

### Resumo das camadas

| Camada | Localização | Materialização | Função |
|--------|-------------|:---:|--------|
| **Raw** | `raw_ecommerce` no BigQuery | Tabelas importadas do CSV | Dados exatamente como vieram do Kaggle |
| **Staging** | `raw_ecommerce_staging` | Views | CASTs explícitos, padronização de nomes, INITCAP/UPPER |
| **Marts** | `raw_ecommerce_marts` | Tables | Star schema: dimensões (surrogate keys MD5) + fatos com métricas |
| **BI** | `raw_ecommerce_marts` | Views | Denormalização para consumo direto do Looker Studio |
| **Dashboard** | Looker Studio | Gráficos e filtros | 4 páginas com KPIs de receita, entregas, produtos e clientes |

A tabela `fct_orders` é a **fato central** do modelo, conectando pedidos a pagamentos, avaliações e dimensões de cliente. Todas as chaves são hashes MD5 gerados via `dbt_utils.generate_surrogate_key`.

## Stack


- **Data Warehouse:** Google BigQuery
- **Transformação:** dbt Core v1.11 (dbt-bigquery)
- **Linguagem:** SQL (dialeto BigQuery) com Jinja
- **Visualização:** Looker Studio (futuro)

## Modelagem

### Camada Staging (8 modelos, materializados como views)

Aplica tipagem explícita, padronização de nomes, `INITCAP` em cidades e `UPPER` em estados.

| Modelo | Descrição |
|--------|-----------|
| `stg_orders` | Pedidos com timestamps convertidos |
| `stg_order_items` | Itens dos pedidos com preço/frete como NUMERIC |
| `stg_customers` | Clientes com cidade/estado padronizados |
| `stg_products` | Produtos com dimensões físicas |
| `stg_payments` | Pagamentos (tipos, parcelas, valores) |
| `stg_reviews` | Avaliações com notas e timestamps |
| `stg_sellers` | Vendedores com localização |
| `stg_geolocation` | Coordenadas geográficas por CEP |

### Camada Marts (7 modelos, materializados como tables)

Star schema com surrogate keys (MD5) e métricas agregadas.

**Dimensões:**
- `dim_customers` — dados demográficos + lifetime orders
- `dim_products` — categoria, peso (kg), volume (cm³)
- `dim_sellers` — localização + lifetime revenue
- `dim_geolocation` — coordenadas médias por CEP (particionada por `zip_code_prefix`, clusterizada por `state`)

**Fatos:**
- `fct_orders` — fato central (ciclo do pedido, delivery delay, métricas financeiras e de review)
- `fct_payments` — valores por tipo de pagamento (credit_card, boleto, voucher, debit_card)
- `fct_reviews` — agregação de notas (avg, min, max, contagem de estrelas)

## Pré-requisitos

- Python 3.14+
- Google Cloud Platform (projeto + service account com BigQuery User + Data Editor)

## Setup

```bash
python -m venv venv
.\venv\Scripts\activate      # Windows
pip install -r requirements.txt
```

Configure `profiles.yml` em `~/.dbt/profiles.yml`:

```yaml
portfolio_ecommerce:
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: [SEU_PROJETO]
      dataset: portfolio_ecommerce
      keyfile: [CAMINHO_DA_CHAVE_JSON]
      location: US
  target: dev
```

## Comandos

| Comando | Descrição |
|---------|-----------|
| `dbt debug` | Testa conexão com BigQuery |
| `dbt deps` | Instala pacotes (dbt_utils) |
| `dbt run` | Executa todos os modelos |
| `dbt test` | Executa testes de qualidade |
| `dbt build` | `run` + `test` em um comando |
| `dbt docs generate` | Gera documentação e lineage |
| `dbt docs serve` | Serve documentação localmente |

## Testes

- **Testes declarativos** em `schema.yml`:
  - `unique` + `not_null` em todas as surrogate keys
  - `accepted_values` para `order_status`
  - `relationships` entre `fct_orders.customer_key` e `dim_customers`
  - `expression_is_true` para valores não negativos
- **Testes singulares** em `tests/assert_*.sql`

## Licença

Projeto de portfólio. Dados do [Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
