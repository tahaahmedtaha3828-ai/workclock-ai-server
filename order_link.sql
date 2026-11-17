-- شغّله مرة واحدة في Supabase > SQL Editor قبل ما ترفع الملفات الجديدة
alter table public.licenses add column if not exists order_id uuid references public.orders(id) on delete set null;

-- يربط التراخيص القديمة بطلباتها (بس لو التطابق واضح ومفيش لبس)
update public.licenses l set order_id = o.id
from public.orders o join public.projects p on p.id = o.project_id
where l.order_id is null and l.product = p.name and l.customer_name = o.customer_name
  and (select count(*) from public.orders o2 join public.projects p2 on p2.id = o2.project_id
       where p2.name = p.name and o2.customer_name = o.customer_name) = 1;
