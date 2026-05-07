<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';

  let product = {};
  let options = [];
  let reviews = [];
  let selectedOptions = {}; // { "Color": "Red", "Size": "M" }

  let newReview = { user_id: 1, rating: 5, comment: '' };

  $: creatorId = $page.params.id;
  $: productId = $page.params.product_id;

  // gruppera options per type
  $: groupedOptions = options.reduce((acc, opt) => {
    if (!acc[opt.option_type]) acc[opt.option_type] = [];
    acc[opt.option_type].push(opt);
    return acc;
  }, {});

  // räkna ut totalpris med modifiers
  $: totalPrice = (() => {
    const base = product.base_price ?? 0;
    const extra = Object.values(selectedOptions).reduce((sum, val) => {
      const opt = options.find(o => o.value === val);
      return sum + (opt?.price_modifier ?? 0);
    }, 0);
    return base + extra;
  })();

  async function fetchProduct() {
    const res = await fetch(`http://localhost:4567/api/creators/${creatorId}/products/${productId}`);
    const data = await res.json();
    product = data.product;
    options = data.options;
  }

  async function fetchReviews() {
    const res = await fetch(`http://localhost:4567/api/creators/${creatorId}/products/${productId}/reviews`);
    reviews = await res.json();
  }

  async function addReview() {
    await fetch(`http://localhost:4567/api/creators/${creatorId}/products/${productId}/reviews`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newReview)
    });
    newReview.comment = '';
    await fetchReviews();
  }

  function avgRating(reviews) {
    if (!reviews.length) return null;
    return (reviews.reduce((a, r) => a + r.rating, 0) / reviews.length).toFixed(1);
  }

  onMount(async () => {
    await fetchProduct();
    await fetchReviews();
  });
</script>

<div class=" px-4 py-10 text-neutral-200 bg-neutral-950">

  <!-- PRODUCT HEADER -->
  <div class="rounded-2xl border border-neutral-800 bg-neutral-900 overflow-hidden mb-6">
    {#if product.image_url}
      <img src={product.image_url} alt={product.name} class="w-full h-64 object-cover" />
    {:else}
      <div class="w-full h-64 bg-gradient-to-br from-neutral-900 to-violet-950 flex items-center justify-center text-5xl">
        🛍️
      </div>
    {/if}

    <div class="p-6">
      <div class="flex items-start justify-between gap-4">
        <h1 class="text-2xl font-bold text-neutral-100 leading-tight">{product.name}</h1>
        {#if product.price}
          <span class="text-xl font-semibold text-violet-400 shrink-0">${product.price}</span>
        {/if}
      </div>

      {#if avgRating(reviews)}
        <div class="flex items-center gap-1.5 mt-2 mb-3">
          <span class="text-yellow-400 text-sm">{'★'.repeat(Math.round(avgRating(reviews)))}{'☆'.repeat(5 - Math.round(avgRating(reviews)))}</span>
          <span class="text-xs text-neutral-500">{avgRating(reviews)} · {reviews.length} review{reviews.length !== 1 ? 's' : ''}</span>
        </div>
      {/if}

      {#if product.description}
        <p class="text-sm text-neutral-400 leading-relaxed mt-2">{product.description}</p>
      {/if}
    </div>
  </div>

  <!-- OPTIONS -->
{#if Object.keys(groupedOptions).length > 0}
  <div class="mb-6">
    <p class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium mb-4">Options</p>

    {#each Object.entries(groupedOptions) as [typeName, values]}
      <div class="mb-4">
        <p class="text-sm text-neutral-400 mb-2">
          {typeName}
          {#if selectedOptions[typeName]}
            <span class="text-neutral-200 ml-1">— {selectedOptions[typeName]}</span>
          {/if}
        </p>
        <div class="flex flex-wrap gap-2">
          {#each values as opt}
            {@const isSelected = selectedOptions[typeName] === opt.value}
            <button
              on:click={() => selectedOptions = { ...selectedOptions, [typeName]: opt.value }}
              class="px-4 py-2 rounded-xl border text-sm transition-all
                {isSelected
                  ? 'border-violet-500 bg-violet-500/20 text-violet-300'
                  : 'border-neutral-700 bg-neutral-900 text-neutral-400 hover:border-neutral-500'}"
            >
              {opt.value}
              {#if opt.price_modifier > 0}
                <span class="text-xs ml-1 {isSelected ? 'text-violet-400' : 'text-neutral-600'}">
                  +${opt.price_modifier}
                </span>
              {/if}
            </button>
          {/each}
        </div>
      </div>
    {/each}

    <!-- total pris -->
    <div class="mt-4 flex items-center justify-between border-t border-neutral-800 pt-4">
      <span class="text-sm text-neutral-400">Total</span>
      <span class="text-xl font-bold text-violet-400">${totalPrice}</span>
    </div>

    <!-- add to cart -->
    <button class="mt-4 w-full py-3 rounded-xl bg-violet-600 hover:bg-violet-500 text-white font-medium transition-colors">
      Add to cart
    </button>
  </div>
{/if}

  <!-- ADD REVIEW -->
  <div class="rounded-2xl border border-neutral-800 bg-neutral-900 p-6">
    <p class="text-[10px] uppercase tracking-widest text-neutral-500 font-medium mb-4">Leave a review</p>

    <form on:submit|preventDefault={addReview} class="flex flex-col gap-3">

      <!-- STAR PICKER -->
      <div class="flex gap-1">
        {#each [1,2,3,4,5] as star}
          <button
            type="button"
            on:click={() => newReview.rating = star}
            class="text-2xl transition-colors {newReview.rating >= star ? 'text-yellow-400' : 'text-neutral-700'} hover:text-yellow-300"
          >★</button>
        {/each}
      </div>

      <textarea
        bind:value={newReview.comment}
        placeholder="Write your review..."
        rows="3"
        class="w-full bg-neutral-800 border border-neutral-700 rounded-xl px-4 py-3 text-sm text-neutral-200 placeholder-neutral-600 resize-none focus:outline-none focus:border-neutral-500"
      ></textarea>

      <button
        type="submit"
        class="self-end px-6 py-2 rounded-full bg-violet-600 hover:bg-violet-500 text-white text-sm font-medium transition-colors"
      >
        Submit
      </button>

    </form>
  </div>

</div>