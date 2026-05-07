<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';

  let creator = null;
  let socials = [];
  let products = [];
  let categories = [];
  let loading = true;


  $: creatorId = $page.params.id;

  async function loadCreator() {
    loading = true;

    const res = await fetch(`http://localhost:4567/api/creators/${creatorId}`);
    const data = await res.json();

    creator = data.creator;
    socials = data.socials;
    products = data.merch;
    categories = data.categories;

    loading = false;
  }

  const platformLogoMap = {
  youtube:   { url: 'https://www.google.com/s2/favicons?domain=youtube.com&sz=64' },
  twitch:    { url: 'https://www.google.com/s2/favicons?domain=twitch.tv&sz=64' },
  instagram: { url: 'https://www.google.com/s2/favicons?domain=instagram.com&sz=64' },
  twitter:   { url: 'https://www.google.com/s2/favicons?domain=twitter.com&sz=64' },
  tiktok:    { url: 'https://www.google.com/s2/favicons?domain=tiktok.com&sz=64' },
  default:   { url: null }
};

function platformLogo(platform) {
  return platformLogoMap[platform?.toLowerCase()] ?? platformLogoMap.default;
}

function formatFollowers(n) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + 'M';
  if (n >= 1_000) return (n / 1_000).toFixed(0) + 'K';
  return n;
}

  onMount(loadCreator);
</script>

{#if loading}
  <p>Loading creator...</p>
{:else}

 <div class=" bg-neutral-950 text-neutral-200 overflow-hidden">

  <div class="w-full h-52 sm:h-80 bg-gradient-to-br from-neutral-900 via-indigo-950 to-violet-950 overflow-hidden">
    {#if creator.profile_image}
      <img src={creator.profile_image} alt="Banner" class="w-full h-full object-cover" />
    {/if}
  </div>

  <div class="flex -mt-12 sm:-mt-20 relative justify-center">
    <div class="w-24 sm:w-40 h-24 sm:h-40 rounded-full border-4 border-neutral-950 bg-gradient-to-br from-violet-500 to-teal-400 flex items-center justify-center text-3xl font-bold text-white overflow-hidden">
      {#if creator.profile_image}
        <img src={creator.profile_image} alt={creator.name} class="w-full h-full object-cover" />
      {:else}
        {creator.name?.[0]?.toUpperCase() ?? '?'}
      {/if}
    </div>
  </div>

  <div class="px-7 pt-4 pb-0">
    <h1 class="text-2xl font-bold text-neutral-100 leading-tight text-center">{creator.name}</h1>
    <p class="text-sm text-neutral-100 mt-0.5 mb-2 text-center">@{creator.username}</p>
    {#if categories.length > 0}
      <div class="flex flex-wrap gap-1 mb-5 justify-center w-70 mx-auto">
        {#each categories as cat}
          <span class="text-[0.7rem] uppercase tracking-widest font-medium px-2 py-1 rounded bg-neutral-800 text-neutral-400 border border-neutral-700">
            {cat.name}
          </span>
        {/each}
      </div>
    {/if}
  </div>

  <hr class="border-neutral-800 mx-7" />

  <div class="grid grid-cols-3 px-7 py-5">
    <div class="flex flex-col gap-1">
      <span class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium">Nationality</span>
      <span class="text-lg font-semibold text-neutral-100">{creator.nationality ?? '—'}</span>
    </div>
    <div class="flex flex-col gap-1 border-l border-neutral-800 pl-5">
      <span class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium">Real name</span>
      <span class="text-lg font-medium text-neutral-100 pt-1">{creator.real_name ?? '—'}</span>
    </div>
    <div class="flex flex-col gap-1 border-l border-neutral-800 pl-5">
      <span class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium">Age</span>
      <span class="text-lg font-semibold text-neutral-100">{creator.age ?? '—'}</span>
    </div>
  </div>

  <hr class="border-neutral-800 mx-7" />

  <div>
  <div class="px-7 py-5">
  <p class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium mb-3">Socials</p>
  {#if socials.length === 0}
    <p class="text-sm text-neutral-600">No social links yet.</p>
  {:else}
    <div class="grid grid-cols-4 gap-2">
      {#each socials as social}
        {@const style = platformLogo(social.platform)}
        
        <a href={social.url ?? '#'}
          target="_blank"
          rel="noopener noreferrer"
          class="flex flex-col items-center gap-1 px-1 py-1 rounded-xl border border-neutral-800 bg-neutral-900 hover:bg-neutral-800 hover:border-neutral-600 transition-colors no-underline text-inherit"
        >
          <div class="w-8 h-8 rounded-lg bg-neutral-800 flex items-center justify-center shrink-0 overflow-hidden">
            {#if style.url}
              <img src={style.url} alt={social.platform} class="w-8 h-8 object-contain" />
            {:else}
              <span class="text-xs font-bold text-white">{social.platform[0]}</span>
            {/if}
          </div>
          <div class="flex-1">
            <div class="text-xs text-neutral-400">@{social.username}</div>
          </div>
          <div class="text-xs font-medium text-neutral-100">{formatFollowers(social.followers)}</div>
        </a>
      {/each}
    </div>
  {/if}
</div>

  {#if creator.about_me}
    <div class="px-7 py-5">
      <p class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium mb-3">About</p>
      <p class="text-sm text-neutral-400 leading-relaxed font-light">{creator.about_me} I appreciate destroying my friends in fun minigames and jumping through many obstacles, I have partnered with other massive youtubers like pewdiepie and jackseptiqye creating a strong bond for the minecraft community. I am also top 5 in the fastest speedrunners in the world</p>
    </div>
    <hr class="border-neutral-800 mx-7" />
  {/if}

  </div>

 

  <hr class="border-neutral-800 mx-7" />

  <div class="px-7 py-5">
    <p class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium mb-3">Merch</p>
    {#if products.length === 0}
      <p class="text-sm text-neutral-600">No products yet.</p>
    {:else}
      <div class="grid gap-2.5">
        {#each products as product}
          
          <a href={`/creators/${creatorId}/products/${product.id}`}
            class="rounded-xl border border-neutral-800 bg-neutral-900 overflow-hidden hover:border-neutral-600 hover:bg-neutral-800 transition-colors no-underline text-inherit block"
          >
            {#if product.image_url}
              <img src={product.image_url} alt={product.name} class="w-full h-28 object-cover" />
            {:else}
              <div class="w-full h-50 bg-gradient-to-br from-neutral-900 to-violet-950 flex items-center justify-center text-2xl">
                🛍️
              </div>
            {/if}
            <div class="px-3 py-2.5">
              <div class="text-sm font-medium text-neutral-200">{product.name}</div>
              <div class="text-xs text-neutral-500 mt-0.5">View product →</div>
            </div>
          </a>
        {/each}
      </div>
    {/if}
  </div>

  {#if creator.updated_at}
    <p class="px-7 pb-5 text-[11px] text-neutral-700 tracking-wide">
      Last updated: {creator.updated_at}
    </p>
  {/if}

</div>

{/if}