const PLANS={monthly:'اشتراك شهري',yearly:'اشتراك سنوي',once:'شراء كامل (مرة واحدة)'};
const SUFFIX={monthly:'/ شهر',yearly:'/ سنة',once:'مرة واحدة'};
const DEFAULT_CATS=[['برامج إدارية'],['برامج محاسبية'],['برامج سطح المكتب'],['حلول ويب']];
const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const priceText=(p,plan)=>Number(p).toLocaleString('en')+' ج.م '+SUFFIX[plan];
const READY=!/PASTE/.test(SUPABASE_URL+SUPABASE_KEY);
const sb=READY?supabase.createClient(SUPABASE_URL,SUPABASE_KEY):null;
if(!READY)addEventListener('DOMContentLoaded',()=>document.body.insertAdjacentHTML('afterbegin','<div class="banner">كمّل الإعداد: الصق بيانات Supabase في ملف config.js</div>'));
async function requireAdmin(){if(!READY)return false;const{data}=await sb.auth.getSession();if(!data.session){location.href='login.html';return false}return true}
const fileUrl=(path,name)=>sb.storage.from('programs').getPublicUrl(path,{download:name||true}).data.publicUrl;
