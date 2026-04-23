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

  onMount(loadCreator);
</script>

{#if loading}
  <p>Loading creator...</p>
{:else}

  <!-- HEADER -->
  <section style="padding:20px; border-bottom:1px solid #ddd;">
    <h1>{creator.name}</h1>

    <p>{creator.about_me}</p>

    <p><strong>Username:</strong> @{creator.username}</p>
    <p><strong>Real name:</strong> {creator.real_name}</p>
    <p><strong>Nationality:</strong> {creator.nationality}</p>
    <p><strong>Age:</strong> {creator.age}</p>
    <p><strong>Categories:</strong> 
      {#if categories.length === 0}
        None
      {:else}
        #{categories.map(c => c.name).join(', ')}
      {/if}
    </p>


    {#if creator.updated_at}
      <p style="opacity:0.6; font-size:0.9rem;">
        Last updated: {creator.updated_at}
      </p>
    {/if}
  </section>

  <!-- SOCIALS -->
  <section style="padding:20px;">
    <h2>Social Links</h2>

    {#if socials.length === 0}
      <p>No social links.</p>
    {:else}
      <ul>
        {#each socials as social}
          <li>
            <strong>{social.platform}</strong>:
            {social.username}
            ({social.followers} followers)
          </li>
        {/each}
      </ul>
    {/if}
  </section>

  <!-- PRODUCTS -->
  <section style="padding:20px;">
    <h2>Products</h2>

    {#if products.length === 0}
      <p>No products yet.</p>
    {:else}
      <ul>
        {#each products as product}
          <li>
            <a class="outline rounded" href={`/creators/${creatorId}/products/${product.id}`}>
              {product.name}
            </a>
          </li>
        {/each}
      </ul>
    {/if}
  </section>

{/if}