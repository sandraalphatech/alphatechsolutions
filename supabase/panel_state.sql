-- ============================================================
-- Alpha Leads: guardar TODOS os dados do painel na base de dados
-- Cole TUDO isto em: Supabase > SQL Editor > New query > Run
-- É seguro executar mais de uma vez.
-- ============================================================

create table if not exists public.panel_state (
  id          text primary key,
  data        jsonb not null default '{}'::jsonb,
  rev         integer not null default 0,        -- versão: evita que dois dispositivos se sobreponham
  updated_at  timestamptz not null default now(),
  constraint panel_state_id_chk check (id = 'main')
);

alter table public.panel_state enable row level security;
revoke all on table public.panel_state from anon, authenticated;
grant select, insert, update on table public.panel_state to authenticated;

-- Só a Sandra (e-mail abaixo), com sessão iniciada, lê e escreve. Visitantes anónimos: nada.
drop policy if exists "dona le estado" on public.panel_state;
create policy "dona le estado" on public.panel_state
  for select to authenticated
  using ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com');

drop policy if exists "dona cria estado" on public.panel_state;
create policy "dona cria estado" on public.panel_state
  for insert to authenticated
  with check ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com');

drop policy if exists "dona atualiza estado" on public.panel_state;
create policy "dona atualiza estado" on public.panel_state
  for update to authenticated
  using ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com');

-- Verificação: deve mostrar rls_ativa = true e politicas = 3
select
  (select relrowsecurity from pg_class where oid = 'public.panel_state'::regclass) as rls_ativa,
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'panel_state') as politicas;
