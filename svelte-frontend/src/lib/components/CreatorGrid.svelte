<script>
  import { onMount } from 'svelte';
  import CreatorCard from '../side_components/CreatorCard.svelte';

  let creators = [];
  let categories = []; 
  
  let searchTerm = '';
  let selectedCategoryId = 'All';
  let minAge = 0;
  let maxAge = 100;

  onMount(async () => {
    const [creatorsRes, categoriesRes] = await Promise.all([
      fetch('http://localhost:4567/api/creators'),
      fetch('http://localhost:4567/api/categories')
    ]);
    
    creators = (await creatorsRes.json()).map(c => ({
      ...c,
      category_ids: JSON.parse(c.category_ids || '[]')
    }));
    categories = await categoriesRes.json();
  });

  $: filteredCreators = creators.filter(c => {
    const matchesSearch = c.name.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesCategory = selectedCategoryId === 'All' || 
                            c.category_ids?.some(id => id == selectedCategoryId);
    
    const age = c.age != null ? Number(c.age) : null;
    const matchesAge = age == null || (age >= minAge && age <= maxAge);

    return matchesSearch && matchesCategory && matchesAge;
  });

  $: console.log('creators:', creators);
  $: console.log('filtered:', filteredCreators);
</script>

<div class="grid p-8">
    <div class="flex flex-wrap gap-4 mb-8 items-center bg-gray-100 p-4 rounded-lg">
        <input type="text" placeholder="Sök namn..." bind:value={searchTerm} class="border p-2 rounded shadow-sm"/>

        <select bind:value={selectedCategoryId} class="border p-2 rounded shadow-sm">
            <option value="All">Alla kategorier</option>
            {#each categories as cat}
                <option value={cat.id}>{cat.name}</option>
            {/each}
        </select>

        <div class="flex items-center gap-2 bg-white p-2 rounded border shadow-sm">
            <span class="text-sm font-semibold">Age:</span>
            <input type="number" bind:value={minAge} class="w-16 p-1 border-b" min="0" />
            <span>till</span>
            <input type="number" bind:value={maxAge} class="w-16 p-1 border-b" min="0" />
        </div>
    </div>

    <div class="grid grid-cols-2 gap-4">
        {#each filteredCreators as creator}
            <CreatorCard {creator} />
        {/each}
        
        {#if filteredCreators.length === 0}
            <p>No creators match</p>
        {/if}
    </div>
</div>