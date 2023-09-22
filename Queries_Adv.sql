--POSTGREES!

-----------------------------------COMANDOS BÁSICOS-------------------------------------------
-----------------------Selecione os nomes de cidade distintas que existem no estado de Minas Gerais em ordem alfabética (dados da tabela sales.customers)
select distinct city
from sales.customers
where state = 'MG'
order by city asc;

-----------------------Selecione o visit_id das 10 compras mais recentes efetuadas(dados da tabela sales.funnel)
select visit_id,
       add_to_cart_date
from sales.funnel
where paid_date is not null
order by paid_date asc
limit 10;

-----------------------Selecione todos os dados dos 10 clientes com maior score nascidos após 01/01/2000 (dados da tabela sales.customers)
select * 
from sales.customers
where birth_date >= '01/01/2000'
order by score desc
limit 10;


-----------------------------------------OPERADORES----------------------------------------------------------
------------------------Calcule quantos salários mínimos ganha cada cliente da tabela sales.customers. Selecione as colunas de: email, income e a coluna calculada "salários mínimos". Considere o salário mínimo igual à R$1200
select email,
       income,
	   income / 1250  as quantidade_salários_min
from sales.customers;

------------------------Na query anterior acrescente uma coluna informando TRUE se o cliente ganha acima de 5 salários mínimos e FALSE se ganha 4 salários ou menos. Chame a nova coluna de "acima de 4 salários"
select email,
       income,
	   income / 1250           as quantidade_salários_min,
	   ((income) / 1250) >= 4  as acima_de_4_salários
from sales.customers;

------------------------Na query anterior filtre apenas os clientes que ganham entre 4 e 5 salários mínimos. Utilize o comando BETWEEN
select email,
       income,
	   income / 1250           as quantidade_salários_min,
	   ((income) / 1250) >= 4  as acima_de_4_salários
from sales.customers
where (income / 1250) between 4 and 5;

------------------------Selecine o email, cidade e estado dos clientes que moram no estado de Minas Gerais e Mato Grosso.
select email,
       city,
	   state
from sales.customers
where state in ('MG','MT');

------------------------Selecine o email, cidade e estado dos clientes que não moram no estado de São Paulo.
select email,
       city,
	   state
from sales.customers
where  state not in ('SP');

------------------------Selecine os nomes das cidade que começam com a letra Z. Dados da tabela temp_table.regions
select city
from temp_tables.regions
where city ilike 'z%';


-------------------------------------------FUNÇÕES AGREGADAS---------------------------------------------
-------------------------Conte quantos clientes da tabela sales.customers tem menos de 30 anos
select count(*)
from sales.customers
where ((current_date - birth_date) / 365) < 30;

---------------------Informe a idade do cliente mais velho e mais novo da tabela sales.customers
select max((current_date - birth_date)/365) as mais_velho,
       min((current_date - birth_date)/365) as mais_novo
from sales.customers;

---------------------Selecione todas as informações do cliente mais rico da tabela sales.customers(possívelmente a resposta contém mais de um cliente)
select *
from sales.customers
where income = (
	            select max(income)
			    from sales.customers
               );	

---------------------Conte quantos veículos de cada marca tem registrado na tabela sales.products.Ordene o resultado pelo nome da marca
select count(product_id) as quantidade_carros,
       brand             as marca
from sales.products
group by brand
order by brand;

---------------------Conte quantos veículos existem registrados na tabela sales.products por marca e ano do modelo. Ordene pela nome da marca e pelo ano do veículo
select count(product_id)   as quantidade_carros,
       brand               as marca, 
	   model_year          as ano
from sales.products
group by brand, model_year
order by brand, model_year;	   

---------------------Conte quantos veículos de cada marca tem registrado na tabela sales.products e mostre apenas as marcas que contém mais de 10 veículos registrados
select count(product_id) as quantidade_carros,
       brand
from sales.products
group by brand
having count(*) > 10
order by count(product_id) desc;


-------------------------------------------JOINS---------------------------------------------
---------------------Identifique quais as marcas de veículo mais visitada na tabela sales.funnel       
select pro.brand,
	   count(*)          as visitas
from sales.funnel        as fun
left join sales.products as pro
on fun.product_id = pro.product_id
group by pro.brand
order by visitas desc

---------------------Identifique quais as lojas de veículo mais visitadas na tabela sales.funnel
select 
	sto.store_name,
	count(*)           as visitas
from sales.funnel      as fun
left join sales.stores as sto
on fun.store_id = sto.store_id
group by sto.store_name
order by visitas desc

---------------------Identifique quantos clientes moram em cada tamanho de cidade (o porte da cidade consta na coluna "size" da tabela temp_tables.regions)
select reg.size,
	   count(*)               as contagem
from sales.customers          as cus
left join temp_tables.regions as reg
on lower(cus.city) = lower(reg.city)
and lower(cus.state) = lower(reg.state)
group by reg.size
order by contagem


-------------------------------------------UNIONS---------------------------------------------
---------------------União simples de duas tabelas. Una a tabela sales.products com a tabela temp_tables.products_2
select * 
from sales.products
union all
select * 
from temp_tables.products_2;


-------------------------------------------SUBQUERYES---------------------------------------------
---------------------Subquery com WHERE. Calcule a idade média dos clientes por status profissional
select *
from sales.products
where price = (select min(price) from sales.products);

---------------------Subquery com WITH Calcule a idade média dos clientes por status profissional
with tabela_exemplo as (
select professional_status,
	   (current_date - birth_date) / 365 as idade
from sales.customers
)
select professional_status,
       avg(idade)                        as media_idade
from tabela_exemplo

---------------------Subquery no FROM. Calcule a média de idades dos clientes por status profissional
select professional_status,
	   avg(idade) as idade_media
from ( select professional_status,
			 (current_date - birth_date)/365 as idade
	  from sales.customers )                 as alguma_tabela
group by professional_status

---------------------Subquery no SELECT. Na tabela sales.funnel crie uma coluna que informe o nº de visitas acumuladas que a loja visitada recebeu até o momento
select fun.visit_id,
       fun.visit_page_date,
	   sto.store_name,
	   (
	   select count(*)
	   from sales.funnel as fun2
	   where fun2.visit_page_date <= fun.visit_page_date 
	   and fun2.store_id = fun.store_id
	   )                 as visitas_acumuladas       
from sales.funnel        as fun
left join sales.stores   as sto
on fun.store_id = sto.store_id
order by sto.store_name, fun.visit_page_date


select fun.visit_id,
       fun.visit_page_date,
	   sto.store_name,
	   (
	   select count(*)
	   from sales.funnel as fun2
	   where fun2.visit_page_date <= fun.visit_page_date 
	   and fun2.store_id = fun.store_id
	   )                 as visitas_acumuladas       
from sales.funnel        as fun
left join sales.stores   as sto
on fun.store_id = sto.store_id
where  (select count(*)
	   from sales.funnel as fun2
	   where fun2.visit_page_date <= fun.visit_page_date 
	   and fun2.store_id = fun.store_id) >= 15   ----> trazer as visitas acumuladas (linha 199), que forem maior ou igual que 15 
order by sto.store_name, fun.visit_page_date

-------------------------------------------CRUD---------------------------------------------
---------------------INSERIR de Colunas. Insira uma coluna na tabela sales.customers com a idade do cliente
alter table sales.customers
add customer_age int   ----> adiciona a coluna 'customer_age' na tabela, 'sales.customers'

update sales.customers
set customer_age = date_part('year', age(birth_date))   ----> age para calcular a diferença de anos entre a data de nascimento (birth_date) e a data atual
where true

---------------------ATUALIZAÇÃO de linhas. Corrija a tradução de 'estagiário(a)' de 'trainee' para 'intern' 
update temp_tables.profissoes
set professional_status = 'intern'
where status_profissional = 'estagiario(a)';

---------------------DELETAR de linhas. Delete as linhas dos status 'desempregado(a)' e 'estagiário(a)'
delete from temp_tables.profissoes
where status_profissional = 'desempregado(a)'
or status_profissional = 'estagiario(a)'


-------------------------------------------PROJETO DE PERFIL DOS CLIENTES---------------------------------------------
---------------------Gênero dos leads. Colunas: gênero, leads(#)
select
      case
	      when ibge.gender = 'male' then 'masculino'
		  when ibge.gender = 'female'then 'feminino'
	      end                           as "gênero",
	  count(*)                          as "leads(#)"
from sales.customers                    as cus
left join temp_tables.ibge_genders      as ibge
         on lower(cus.first_name) = lower(ibge.first_name)
group by ibge.gender

---------------------Status profissional dos leads. Colunas: status profissional, leads (%)
select 
                case
				    when professional_status = 'freelancer' then 'freelancer'
					when professional_status = 'clt' then 'carteira assinada'
					when professional_status = 'retired' then 'aposentado'
					when professional_status = 'other' then 'outros'
					when professional_status = 'civil_servant' then 'funcionário público'
					when professional_status = 'businessman' then 'homem de negócios'
					when professional_status = 'self_employed' then 'autônomo'
					when professional_status = 'student' then 'estudante'
				    end as "status profissional",			
			   count(*)::float/(select count(*) from sales.customers)   as "leads (%)"					
from sales.customers
group by professional_status
order by "leads (%)"

---------------------Faixa etária dos leads. Colunas: faixa etária, leads (%)
select 
      case 
	      when customer_age < 20 then '0-20'
		  when customer_age < 40 then '20-40'
		  when customer_age < 60 then '40-60'
		  when customer_age < 80 then '60-80'
		  else '80+' end as "faixa etária",	 	  
	 count(*)::float/(select count(*) from sales.customers) as "leads (%)"     
from sales.customers
group by "faixa etária"
order by "faixa etária"

---------------------Faixa salarial dos leads. Colunas: faixa salarial, leads (%), ordem
select 
      case 
	      when income < 5000 then '0-5000'
		  when income < 10000 then '5000-10000'
		  when income < 15000 then '10000-15000'
		  when income < 20000 then '15000-20000'
		  else '20000+' end as "faixa salárial",	 	  
	  count(*)::float/(select count(*) from sales.customers) as "leads (%)",
	  case                                                                       
	      when income < 5000 then '1'
		  when income < 10000 then '2'
		  when income < 15000 then '3'
		  when income < 20000 then '4'
		  else '5' end as "ordem",	----> ordenar as faixas, para isso criou-se uma nova coluna. 	  
	  count(*)::float/(select count(*) from sales.customers) as "leads (%)"
from sales.customers
group by "faixa salárial", "ordem"
order by "ordem" asc

---------------------Classificação dos veículos visitados. Colunas: classificação do veículo, veículos visitados (#). Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos
with
	classificacao_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'novo'
				else 'seminovo'
				end as "classificação do veículo"
		
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"classificação do veículo",
	count(*) as "veículos visitados (#)"
from classificacao_veiculos
group by "classificação do veículo"

---------------------Idade dos veículos visitados. Colunas: Idade do veículo, veículos visitados (%), ordem
with
	faixa_de_idade_dos_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'até 2 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 'de 2 à 4 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 'de 4 à 6 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 'de 6 à 8 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 'de 8 à 10 anos'
				else 'acima de 10 anos'
				end as "idade do veículo",
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 1
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 2
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 3
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 4
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 5
				else 6
				end as "ordem"

		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"idade do veículo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados (%)",
	ordem
from faixa_de_idade_dos_veiculos
group by "idade do veículo", ordem
order by ordem

---------------------Veículos mais visitados por marca. Colunas: brand, model, visitas (#)
select
	pro.brand,
	pro.model,
	count(*) as "visitas (#)"

from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"
