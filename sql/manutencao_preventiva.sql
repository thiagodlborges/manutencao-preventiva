-- Módulo Manutenção Preventiva (REG-PE-13-01 / POP-PE-13)
-- Aplicar no SQL Editor do Supabase.

create table if not exists manutencao_equipamentos(
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique, nome text not null, marca_modelo text, localizacao text,
  ativo boolean not null default true, criado_em timestamptz not null default now());
create table if not exists manutencao_planos(
  id uuid primary key default gen_random_uuid(),
  equipamento_id uuid not null references manutencao_equipamentos(id) on delete cascade,
  frequencia text not null check (frequencia in ('D','S','M','Trim','Sem','A')),
  atividade text not null,
  responsavel text,
  meses int[] not null default '{}',
  ativo boolean not null default true, criado_em timestamptz not null default now());
create table if not exists manutencao_execucoes(
  id uuid primary key default gen_random_uuid(),
  plano_id uuid not null references manutencao_planos(id) on delete cascade,
  ano int not null, mes int not null check (mes between 1 and 12),
  data_execucao date not null default current_date,
  executado_por text, os_numero text, observacoes text,
  registrado_por uuid default auth.uid(), criado_em timestamptz not null default now(),
  unique(plano_id, ano, mes));

create or replace function manutencao_pode_ver() returns boolean language sql stable security definer set search_path=public as $$
  select public.is_master() or exists(select 1 from perfil_acessos where perfil_id=auth.uid() and sistema_slug='manutencao') $$;
create or replace function manutencao_pode_editar() returns boolean language sql stable security definer set search_path=public as $$
  select public.is_master() or exists(select 1 from perfis where id=auth.uid() and tipo='fabrica') $$;

alter table manutencao_equipamentos enable row level security;
alter table manutencao_planos enable row level security;
alter table manutencao_execucoes enable row level security;
do $$ declare t text; begin
 foreach t in array array['manutencao_equipamentos','manutencao_planos','manutencao_execucoes'] loop
  execute format('create policy %I on %I for select to authenticated using (manutencao_pode_ver())', t||'_sel', t);
  execute format('create policy %I on %I for all to authenticated using (manutencao_pode_ver() and manutencao_pode_editar()) with check (manutencao_pode_ver() and manutencao_pode_editar())', t||'_all', t);
 end loop; end $$;

insert into sistemas(slug,nome,url,icone,ordem,ativo) values
 ('manutencao','Manutenção Preventiva','https://thiagodlborges.github.io/manutencao-preventiva/','🛠️',19,true)
 on conflict (slug) do nothing;

-- Carga inicial: cronograma 2026

insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('FR-CAM-01','Câmara Fria (1)','THERMO KING (12 Kw / 12 m³)','Câmara Fria') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('FR-CAM-02','Câmara Fria (2)','LIAMAC (12 Kw / 24 m³)','Câmara Fria') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('FR-ULT-01','Ultracongelador (1)','TEKNA 5010 NFN (1500W / 1300L)','Produção') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('FR-ULT-02','Ultracongelador (2)','INGECOLD (1000W / 500L)','Produção') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('FR-FRZ-01','Freezer Vertical (1)','Metalfrio VF50FH (750W / 500L)','Estoque Frio') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('FR-FRZ-02','Freezers Horizontais (Conj. 18 un)','Metalfrio NF55SB / NF20SL / NF30SL','Estoque / Exposição') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('PR-PAS-01','Pasteurizador (2 unidades)','SYSTHERM Eurocal-08 (300L)','Produção') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('PR-TIN-01','Tina de Maturação (3 peças)','SYSTHERM (300L)','Produção') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('PR-PRO-01','Produtora de Massa','LIAMAC / CARPIGIANNI / ALOHAGEL','Produção') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('PR-PIC-01','Picoleteira','LIAMAC (10 Kw / 100L)','Produção') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('EM-DES-01','Desenformadora','KAWAMAC - PK60 (30L)','Embalagem') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('PR-MIX-01','Mixers Industriais (2 un)','Robot Coupe CMP 250 / MP 450','Preparação') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('EM-FLW-01','Embaladora Flowpack','KAWAMAC - PK 200','Embalagem') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('EM-SEL-01','Seladoras Manuais (2 un)','ISAMAQ (275W)','Embalagem') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('UT-BAG-01','Banco de Água Gelada','FLEX COLD (10 Kw / 1000L)','Utilidades') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('UT-TOR-01','Torre de Refrigeração','VM (2 Hp / 150L)','Utilidades') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('UT-AQU-01','Aquecedor de Água','THERMOTINI CV 300 (300L)','Utilidades') on conflict (codigo) do nothing;
insert into manutencao_equipamentos(codigo,nome,marca_modelo,localizacao) values ('UT-GLP-01','Estação de GLP','ULTRAGAZ (190 Kg)','Externo') on conflict (codigo) do nothing;

insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'M','Verificação de gás, limpeza de condensadora/evaporadora. Verificação de compressores, gaxetas, alinhamento de portas e nível de fluído','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-CAM-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Teste de degelo.','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-CAM-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'M','Verificação de gás, limpeza de condensadora/evaporadora. Verificação de compressores, gaxetas, alinhamento de portas e nível de fluído','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-CAM-02';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Teste de degelo.','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-CAM-02';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Higienização de serpentina, checagem de ventoinhas, sensores de temperatura. Limpeza de condensadores, verificação do ciclo de congelamento.','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-ULT-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Higienização de serpentina, checagem de ventoinhas, sensores de temperatura. Limpeza de condensadores, verificação do ciclo de congelamento.','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-ULT-02';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'S','Limpeza de grades/condensador, teste de vedação de borrachas e termostato','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-FRZ-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'S','Limpeza de grades/condensador, teste de vedação de borrachas e termostato','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='FR-FRZ-02';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'M','Checagem de bombas, gaxetas sanitárias, placas, vedações e teste de pressão','Terc./Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='PR-PAS-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'M','Revisão dos agitadores, motor-redutor, gaxetas de vedação e isolamento térmico','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='PR-TIN-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Lubrificação H1 (grau alimentício), verificação de lâminas/raspadores e correias','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='PR-PRO-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'M','Verificação da circulação do fluido, agitadores, vedações e parte elétrica','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='PR-PIC-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Nível do líquido de refrigeração','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='PR-PIC-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'Trim','Inspeção de resistências/banho-maria, termostato, gaxetas e válvulas','Manut.','{1,4,7,10}' from manutencao_equipamentos where codigo='EM-DES-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Inspeção de cabos elétricos',null,'{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='PR-MIX-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Inspeção e regulagem antes do inicio de produção, ajuste de facas/mordentes, lubrificação H1, checagem de esteira e sensores, lubrificação H1, checagem de esteira e sensores','Terc./Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='EM-FLW-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'Trim','Substituição da fita teflon, verificação de resistência e ajuste de temperatura','Manut.','{1,4,7,10}' from manutencao_equipamentos where codigo='EM-SEL-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'S','Limpeza de filtros, agitador do fluído','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-BAG-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Nível do líquido de refrigeração e temperatura.','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-BAG-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'S','Limpeza do enchimento, verificação de bicos aspersores, ventilador e tratamento de água','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-TOR-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'S','Inspeção de válvulas de segurança, queimadores/resistências e descalcificação.','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-AQU-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Monitoramento de temperatura','Manut.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-AQU-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'D','Nível de pressão','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-GLP-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'S','Verificação de manômetros, válvulas e reguladores de pressão','Terc.','{1,2,3,4,5,6,7,8,9,10,11,12}' from manutencao_equipamentos where codigo='UT-GLP-01';
insert into manutencao_planos(equipamento_id,frequencia,atividade,responsavel,meses) select id,'Sem','Teste de estanqueidade, verificação de manômetros, válvulas e reguladores de pressão','Terc.','{3,9}' from manutencao_equipamentos where codigo='UT-GLP-01';
