with orders as (
    select
        order_id,
        order_key,
        purchased_at,
        delivery_status,
        delivery_delay_days
    from {{ ref('fct_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

sellers as (
    select * from {{ ref('dim_sellers') }}
),

final as (
    select
        oi.order_id,
        o.order_key,
        o.purchased_at,
        o.delivery_status,
        o.delivery_delay_days,
        oi.order_item_sequence,
        oi.product_id,
        p.product_key,
        p.product_category_name,
        case
            when p.product_category_name in ('casa_conforto', 'casa_conforto_2')
                then 'Casa e Conforto'
            when p.product_category_name in (
                'casa_construcao',
                'construcao_ferramentas_construcao',
                'construcao_ferramentas_ferramentas',
                'construcao_ferramentas_iluminacao',
                'construcao_ferramentas_jardim',
                'construcao_ferramentas_seguranca',
                'ferramentas_jardim')
                then 'Construção e Ferramentas'
            when p.product_category_name in (
                'eletrodomesticos',
                'eletrodomesticos_2',
                'eletroportateis',
                'portateis_casa_forno_e_cafe',
                'portateis_cozinha_e_preparadores_de_alimentos')
                then 'Eletrodomésticos'
            when p.product_category_name in (
                'fashion_bolsas_e_acessorios',
                'fashion_calcados',
                'fashion_esporte',
                'fashion_roupa_feminina',
                'fashion_roupa_infanto_juvenil',
                'fashion_roupa_masculina',
                'fashion_underwear_e_moda_praia',
                'malas_acessorios')
                then 'Moda e Acessórios'
            when p.product_category_name in (
                'moveis_colchao_e_estofado',
                'moveis_cozinha_area_de_servico_jantar_e_jardim',
                'moveis_decoracao',
                'moveis_escritorio',
                'moveis_quarto',
                'moveis_sala')
                then 'Móveis'
            when p.product_category_name in (
                'livros_importados',
                'livros_interesse_geral',
                'livros_tecnicos',
                'cds_dvds_musicais',
                'dvds_blu_ray',
                'musica')
                then 'Livros, Música e Mídia'
            when p.product_category_name in (
                'alimentos',
                'alimentos_bebidas',
                'bebidas',
                'la_cuisine')
                then 'Alimentos e Bebidas'
            when p.product_category_name in (
                'informatica_acessorios',
                'pcs',
                'pc_gamer',
                'tablets_impressao_imagem',
                'consoles_games')
                then 'Informática e Games'
            when p.product_category_name in (
                'audio',
                'eletronicos',
                'cine_foto')
                then 'Eletrônicos e Áudio'
            when p.product_category_name in ('telefonia', 'telefonia_fixa')
                then 'Telefonia'
            when p.product_category_name in (
                'bebes',
                'fraldas_higiene',
                'brinquedos')
                then 'Bebês e Crianças'
            when p.product_category_name in ('beleza_saude', 'perfumaria')
                then 'Beleza e Perfumaria'
            when p.product_category_name in (
                'artes',
                'artes_e_artesanato',
                'artigos_de_festas',
                'artigos_de_natal',
                'flores',
                'papelaria')
                then 'Artes, Festas e Papelaria'
            when p.product_category_name in (
                'agro_industria_e_comercio',
                'industria_comercio_e_negocios')
                then 'Indústria e Comércio'
            when p.product_category_name = 'automotivo' then 'Automotivo'
            when p.product_category_name = 'cama_mesa_banho' then 'Cama, Mesa e Banho'
            when p.product_category_name = 'climatizacao' then 'Climatização'
            when p.product_category_name = 'cool_stuff' then 'Cool Stuff'
            when p.product_category_name = 'esporte_lazer' then 'Esporte e Lazer'
            when p.product_category_name = 'instrumentos_musicais' then 'Instrumentos Musicais'
            when p.product_category_name = 'market_place' then 'Marketplace'
            when p.product_category_name = 'pet_shop' then 'Pet Shop'
            when p.product_category_name = 'relogios_presentes' then 'Relógios e Presentes'
            when p.product_category_name = 'seguros_e_servicos' then 'Seguros e Serviços'
            when p.product_category_name = 'sinalizacao_e_seguranca' then 'Sinalização e Segurança'
            when p.product_category_name = 'utilidades_domesticas' then 'Utilidades Domésticas'
            when p.product_category_name is null then 'Sem Categoria'
            else initcap(replace(p.product_category_name, '_', ' '))
        end as product_category_group,
        p.product_weight_kg,
        p.product_volume_cm3,
        oi.seller_id,
        s.seller_key,
        s.zip_code_prefix as seller_zip_code_prefix,
        s.seller_city,
        s.seller_state,
        oi.price,
        oi.freight_value,
        round(oi.price + oi.freight_value, 2) as total_item_value
    from order_items oi
    left join orders o on oi.order_id = o.order_id
    left join products p on oi.product_id = p.product_id
    left join sellers s on oi.seller_id = s.seller_id
)

select * from final
