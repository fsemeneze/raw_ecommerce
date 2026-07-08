# 🛒 Projeto: Modern Data Stack para E-commerce (Olist)

## 🎯 Objetivo do Projeto
Demonstrar habilidades avançadas em Analytics Engineering e Engenharia de Dados, atendendo a requisitos reais de mercado: modelagem de dados, construção de pipelines em SQL, testes de qualidade, documentação e governança de dados.

## 🛠️ Stack Tecnológica
* **Data Warehouse:** Google BigQuery
* **Transformação e Orquestração:** dbt Core (CLI)
* **Linguagem:** SQL (Dialeto BigQuery) e Python (Ambiente Virtual)
* **Visualização:** Looker Studio / Power BI (Futuro)

---

## ✅ O que já foi construído (Até o momento)

1. **Desenho da Arquitetura:**
   * Definição do fluxo: `Origem (Kaggle) -> Raw (BigQuery) -> Staging (dbt) -> Marts (dbt) -> BI`.
2. **Configuração de Infraestrutura (Google Cloud):**
   * Criação do projeto e do dataset `raw_ecommerce` no BigQuery.
   * Criação de uma *Service Account* com as regras de menor privilégio (*BigQuery User* e *BigQuery Data Editor*).
   * Geração de chave de segurança JSON.
3. **Configuração do Ambiente de Desenvolvimento (dbt):**
   * Criação do ambiente virtual Python (`venv`).
   * Instalação do `dbt-bigquery`.
   * Configuração do `profiles.yml` conectando o ambiente local ao BigQuery com sucesso (`dbt debug` passou em todas as checagens).
4. **Ingestão de Dados (Camada Raw):**
   * Upload das 4 tabelas principais do [Olist Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) para o BigQuery: `orders`, `order_items`, `customers`, `products`.
5. **Desenvolvimento no dbt (Camada de Staging):**
   * Criação do arquivo `models/staging/sources.yml` para mapear a origem, garantindo a linhagem dos dados.
   * Criação do modelo `stg_orders.sql`: conversão de strings de datas para o formato `TIMESTAMP` nativo.
   * Criação do modelo `stg_order_items.sql`: tipagem rigorosa de dados financeiros e sequenciais.

---

## 🗺️ Roadmap: O Plano Completo (Do Início ao Fim)

O projeto está dividido em etapas incrementais, simulando o fluxo ágil de uma equipe de dados.

### Etapa 1: Setup e Ingestão 🟢 *(Concluído)*
- [x] Configurar GCP e BigQuery.
- [x] Configurar dbt e validar conexão.
- [x] Subir dados brutos (Bloco 1) para a camada `raw`.

### Etapa 2: Limpeza e Padronização (Camada de Staging) 🟡 *(Em andamento)*
- [x] Mapear *sources*.
- [x] Criar `stg_orders` e `stg_order_items`.
- [ ] Criar `stg_customers` e `stg_products` (limpeza de nomes de cidades, unificação de strings).

### Etapa 3: Modelagem Dimensional (Camada de Marts) ⚪ *(Pendente)*
- [ ] Criar tabela fato principal: `fct_orders` (cruzando pedidos e itens, calculando valor total, tempo de entrega).
- [ ] Criar tabelas de dimensão: `dim_customers` e `dim_products`.
- [ ] Aplicar boas práticas de nomenclatura e garantir granularidade correta.

### Etapa 4: Governança, Testes e Documentação ⚪ *(Pendente)*
- [ ] Criar arquivo `schema.yml` na camada de staging e marts.
- [ ] Adicionar testes de `unique` e `not_null` para chaves primárias.
- [ ] Adicionar testes de `accepted_values` para status de pedido.
- [ ] Documentar regras de negócio e descrições de colunas.
- [ ] Gerar o catálogo interativo e a linhagem de dados usando `dbt docs generate`.

### Etapa 5: Enriquecimento (Sprints 2 e 3) ⚪ *(Pendente)*
- [ ] **Módulo Financeiro:** Subir `olist_order_payments_dataset`, criar `stg_payments` e `fct_payments`.
- [ ] **Módulo de Avaliações:** Subir `olist_order_reviews_dataset`, integrar notas de clientes na `fct_orders`.
- [ ] **Otimização de Custos (BigQuery):** Aplicar *Partitioning* e *Clustering* na tabela de Geolocalização para demonstrar proficiência em engenharia.

### Etapa 6: Visualização e Entrega do Portfólio ⚪ *(Pendente)*
- [ ] Conectar a tabela `fct_orders` e as dimensões ao Looker Studio ou Power BI.
- [ ] Criar um Dashboard com KPIs básicos (Receita, Tempo de Entrega, Ticket Médio).
- [ ] Escrever o `README.md` final no GitHub detalhando as decisões de arquitetura e exibindo o grafo de linhagem gerado pelo dbt.