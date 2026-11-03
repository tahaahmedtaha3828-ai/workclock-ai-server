-- الصق الكود ده كله في Supabase > SQL Editor ثم اضغط Run
-- مهم: غيّر الإيميل في السطر اللي تحت لإيميل الأدمن بتاعك
create or replace function public.is_admin() returns boolean
language sql stable as $$ select coalesce(auth.jwt()->>'email','') = 'tahaahmedtaha3828@gmail.com' $$;

create table public.projects(
  id uuid primary key default gen_random_uuid(),
  name text not null, category text not null,
  plan text not null check (plan in ('monthly','yearly','once')),
  price numeric not null default 0, description text default '',
  link text default '', file_path text default '', file_name text default '',
  created_at timestamptz default now());

create table public.orders(
  id uuid primary key default gen_random_uuid(),
  code text unique not null, password text not null, customer_name text not null,
  project_id uuid not null references public.projects(id) on delete cascade,
  plan text not null check (plan in ('monthly','yearly','once')),
  price numeric not null default 0,
  link text default '', file_path text default '', file_name text default '',
  created_at timestamptz default now());

alter table public.projects enable row level security;
alter table public.orders enable row level security;
create policy "admin projects" on public.projects for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin orders" on public.orders for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- العميل ميقدرش يقرا الجداول. بيبعت الكود وكلمة السر لدالة بترجع طلبه هو بس
create or replace function public.get_order(p_code text, p_password text) returns json
language sql security definer set search_path = public as $$
  select json_build_object(
    'customer', o.customer_name, 'project', p.name, 'plan', o.plan, 'price', o.price,
    'order_link', o.link, 'order_file_path', o.file_path, 'order_file_name', o.file_name,
    'project_link', p.link, 'project_file_path', p.file_path, 'project_file_name', p.file_name)
  from orders o join projects p on p.id = o.project_id
  where o.code = p_code and o.password = p_password limit 1 $$;
grant execute on function public.get_order(text,text) to anon, authenticated;

-- تخزين الملفات: القراءة بالرابط، والرفع والحذف للأدمن بس
insert into storage.buckets (id, name, public) values ('programs','programs',true) on conflict (id) do nothing;
create policy "admin files" on storage.objects for all to authenticated
  using (bucket_id = 'programs' and public.is_admin()) with check (bucket_id = 'programs' and public.is_admin());
