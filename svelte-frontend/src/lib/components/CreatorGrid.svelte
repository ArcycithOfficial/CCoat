<script>

  $: filteredCreators = creators.filter(c => {
    const matchesSearch = c.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === '' || selectedCategory === 'All' || c.categories?.includes(selectedCategory);
    return matchesSearch && matchesCategory;
  });
  
  import CreatorCard from '../side_components/CreatorCard.svelte';

  import { onMount } from 'svelte';
  let creators = [];
  let searchTerm = '';

  onMount(async () => {
    const res = await fetch('http://localhost:4567/api/creators');
    creators = await res.json();

// Filtered creators based on search term AND category

  });
</script>
<div class="grid p-8">
    <div class="h-20 flex justify-end gap-2">
        <div class="shadow-md h-10 p-1 rounded-md">
            categories
            
        </div>
        <input type="text" placeholder="Search..." bind:value={searchTerm} class="shadow-md h-10 p-2 rounded-md"/>

            
    </div>

<div class="grid grid-cols-2 gap-4  bg">

    <CreatorCard />
</div>
</div>