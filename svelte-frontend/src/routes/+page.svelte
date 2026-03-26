<script>
  import CreatorHeader from '$lib/components/Header.svelte';
  import CreatorGrid from '$lib/components/CreatorGrid.svelte';
  import { onMount } from 'svelte';
  let creators = [];

  onMount(async () => {
    const res = await fetch('http://localhost:4567/api/creators');
    creators = await res.json();
  });
</script>
<CreatorHeader />

<CreatorGrid />

<h1>Featured Creators</h1>



<style>
  .creator-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 1rem;
  }

  .creator-card {
    padding: 1rem;
    border-radius: 0.5rem;
    box-shadow: 0 0 8px rgba(0,0,0,0.1);
    text-align: center;
    background: white;
  }

  .creator-card img {
    width: 100%;
    border-radius: 0.5rem;
  }
</style>