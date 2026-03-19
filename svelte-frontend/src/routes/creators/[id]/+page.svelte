<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';

  let creator = {};
  let socials = [];
  let products = [];

  $: creatorId = $page.params.id;

  onMount(async () => {
    const res = await fetch(`http://localhost:4567/api/creators/${creatorId}`);
    const data = await res.json();
    creator = data.creator;
    socials = data.socials;
    products = data.merch;
  });
</script>

<h1>{creator.name}</h1>
<p>{creator.about_me}</p>

<h2>Social Links</h2>
<ul>
  {#each socials as social}
    <li>{social.platform}: {social.username} ({social.followers} followers)</li>
  {/each}
</ul>

<h2>Products</h2>
<ul>
  {#each products as product}
    <li>
      <a href={`/creators/${creatorId}/products/${product.id}`}>{product.name}</a>
    </li>
  {/each}
</ul>