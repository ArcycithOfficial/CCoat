<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';

  let product = {};
  let options = [];
  let reviews = [];

  let newReview = {user_id: 1, rating: 5, comment: ''};

  $: creatorId = $page.params.id;
  $: productId = $page.params.product_id;

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

  onMount(async () => {
    await fetchProduct();
    await fetchReviews();
  });
</script>

<h1>{product.name}</h1>
<p>{product.description}</p>

<h2>Options</h2>
<ul>
  {#each options as opt}
    <li>{opt.option_type}: {opt.value} (+${opt.price_modifier})</li>
  {/each}
</ul>

<h2>Reviews</h2>
<ul>
  {#each reviews as review}
    <li>
      Rating: {review.rating} — {review.comment}
    </li>
  {/each}
</ul>

<h3>Add a Review</h3>
<form on:submit|preventDefault={addReview}>
  <input
    type="number"
    bind:value={newReview.rating}
    min="1" max="5"
    placeholder="Rating (1-5)" />

  <textarea
    bind:value={newReview.comment}
    placeholder="Write a review"></textarea>

  <button type="submit">Submit Review</button>
</form>

