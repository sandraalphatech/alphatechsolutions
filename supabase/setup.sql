-- ============================================================
-- Alpha Tech Solutions: pedidos de contacto do site -> painel Alpha Leads
-- Cole TUDO isto em: Supabase > SQL Editor > New query > Run
-- É seguro executar mais de uma vez.
-- ============================================================

-- 1) Tabela dos pedidos que chegam pelo formulário do site
create table if not exists public.inbound_leads (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  name         text not null,
  email        text not null,
  phone        text,
  company      text,
  need         text,
  message      text not null,
  lang         text not null default 'pt',
  consent      boolean not null,
  consent_at   timestamptz not null default now(),
  imported_at  timestamptz,                     -- preenchido pelo painel depois de sincronizar
  constraint inbound_leads_consent_chk  check (consent is true),
  constraint inbound_leads_name_chk     check (char_length(name)    between 1 and 120),
  constraint inbound_leads_email_chk    check (char_length(email)   between 5 and 200 and email like '%@%'),
  constraint inbound_leads_phone_chk    check (phone   is null or char_length(phone)   <= 40),
  constraint inbound_leads_company_chk  check (company is null or char_length(company) <= 160),
  constraint inbound_leads_need_chk     check (need    is null or char_length(need)    <= 160),
  constraint inbound_leads_message_chk  check (char_length(message) between 1 and 2000),
  constraint inbound_leads_lang_chk     check (lang in ('pt','es','en'))
);

-- 2) Travão anti-spam: no máximo 40 pedidos em 10 minutos
-- security definer: a função corre com os direitos do dono da tabela, porque o visitante
-- (anon) não pode ler a tabela e, sem isto, o INSERT dele seria recusado.
create or replace function public.inbound_leads_throttle() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.inbound_leads where created_at > now() - interval '10 minutes') >= 40 then
    raise exception 'demasiados pedidos, tente mais tarde';
  end if;
  return new;
end $$;
revoke all on function public.inbound_leads_throttle() from public, anon, authenticated;

drop trigger if exists trg_inbound_leads_throttle on public.inbound_leads;
create trigger trg_inbound_leads_throttle before insert on public.inbound_leads
  for each row execute function public.inbound_leads_throttle();

-- 3) Segurança: ligar RLS e limpar permissões
alter table public.inbound_leads enable row level security;
revoke all on table public.inbound_leads from anon, authenticated;

-- O site (visitante anónimo) só pode INSERIR. Não pode ler, alterar nem apagar.
grant insert on table public.inbound_leads to anon;
drop policy if exists "site pode inserir" on public.inbound_leads;
create policy "site pode inserir" on public.inbound_leads
  for insert to anon
  with check (consent is true and imported_at is null);

-- Só a Sandra (e-mail abaixo), com sessão iniciada, pode ler, marcar como importado e apagar.
grant select, update, delete on table public.inbound_leads to authenticated;

drop policy if exists "dona le" on public.inbound_leads;
create policy "dona le" on public.inbound_leads
  for select to authenticated
  using ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com');

drop policy if exists "dona atualiza" on public.inbound_leads;
create policy "dona atualiza" on public.inbound_leads
  for update to authenticated
  using ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com');

drop policy if exists "dona apaga" on public.inbound_leads;
create policy "dona apaga" on public.inbound_leads
  for delete to authenticated
  using ((auth.jwt() ->> 'email') = 'sandra.alphatech@gmail.com');

-- Verificação: deve mostrar 4 políticas e rls_ativa = true
select
  (select relrowsecurity from pg_class where oid = 'public.inbound_leads'::regclass) as rls_ativa,
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'inbound_leads') as politicas;
