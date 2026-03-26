<script>
  import CreatorGrid from '$lib/components/CreatorGrid.svelte';


  import { onMount } from 'svelte';
	import Hero from '$lib/side_components/Hero.svelte';
  let creators = [];

  onMount(async () => {
    const res = await fetch('http://localhost:4567/api/creators');
    creators = await res.json();
  });
</script>

<Hero />
<CreatorGrid />


<h1>Featured Creators</h1>



<style>

</style>