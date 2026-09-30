-- Rode tudo no Supabase > SQL Editor

create table profiles(
  id uuid primary key references auth.users on delete cascade,
  nome text, email text, telefone text, empresa text,
  role text default 'cliente',            -- cliente | producao | admin
  aprovado boolean default false,
  criado timestamptz default now());

create table config(
  id int primary key default 1,
  nome_loja text default 'Atacado', logo_url text, cor text default '#1e40af');
insert into config(id) values(1) on conflict do nothing;

create table produtos(
  id bigserial primary key, nome text, descricao text,
  preco numeric(10,2) default 0, quantidade int default 0,
  cor text default '#1e40af', foto_url text, ativo boolean default true);

create table pedidos(
  id bigserial primary key, cliente_id uuid references profiles(id),
  nome text, email text, telefone text, itens jsonb, total numeric(10,2),
  hora_pronto text, status text default 'novo',  -- novo | em_producao | pronto | entregue
  criado timestamptz default now());

create table mensagens(
  id bigserial primary key, cliente_id uuid references profiles(id),
  de uuid, texto text, criado timestamptz default now());

-- cria perfil automaticamente; admin@admin.com vira admin, producao@admin.com vira producao
create function handle_new_user() returns trigger language plpgsql security definer as $$
begin
  insert into profiles(id,email,nome,telefone,empresa,role,aprovado) values(
    new.id,new.email,new.raw_user_meta_data->>'nome',new.raw_user_meta_data->>'telefone',
    new.raw_user_meta_data->>'empresa',
    case new.email when 'admin@admin.com' then 'admin' when 'producao@admin.com' then 'producao' else 'cliente' end,
    new.email in ('admin@admin.com','producao@admin.com'));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

create function is_admin() returns boolean language sql security definer stable as
$$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;
create function is_staff() returns boolean language sql security definer stable as
$$ select exists(select 1 from profiles where id=auth.uid() and role in('admin','producao')) $$;
create function is_ok() returns boolean language sql security definer stable as
$$ select exists(select 1 from profiles where id=auth.uid() and aprovado) $$;

alter table profiles enable row level security;
alter table config enable row level security;
alter table produtos enable row level security;
alter table pedidos enable row level security;
alter table mensagens enable row level security;

create policy p_sel on profiles for select using(id=auth.uid() or is_staff());
create policy p_upd on profiles for update using(is_admin());
create policy p_del on profiles for delete using(is_admin());

create policy c_sel on config for select using(true);
create policy c_upd on config for update using(is_admin());

create policy pr_sel on produtos for select using(is_ok());
create policy pr_all on produtos for all using(is_admin()) with check(is_admin());

create policy pd_sel on pedidos for select using(cliente_id=auth.uid() or is_staff());
create policy pd_ins on pedidos for insert with check(cliente_id=auth.uid() and is_ok());
create policy pd_upd on pedidos for update using(is_staff());

create policy m_sel on mensagens for select using(cliente_id=auth.uid() or is_admin());
create policy m_ins on mensagens for insert with check(
  (cliente_id=auth.uid() and de=auth.uid()) or (is_admin() and de=auth.uid()));

-- Storage para logo e fotos
insert into storage.buckets(id,name,public) values('publico','publico',true) on conflict do nothing;
create policy s_sel on storage.objects for select using(bucket_id='publico');
create policy s_ins on storage.objects for insert with check(bucket_id='publico' and is_admin());
