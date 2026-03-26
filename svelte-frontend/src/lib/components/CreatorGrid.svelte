<script>
  import CreatorCard from '../side_components/CreatorCard.svelte';

  import { onMount } from 'svelte';
  let creators = [];

  onMount(async () => {
    const res = await fetch('http://localhost:4567/api/creators');
    creators = await res.json();
  });
</script>
<div class="grid p-8">
    <div class="h-20 flex justify-end gap-4">
        <div class="shadow-md h-10 p-1 rounded-md">
            categories
            
        </div>
        <div class="shadow-md h-10 p-1 rounded-md">
            search
            
        </div>
    </div>

<div class="grid grid-cols-4 gap-4  bg">

    <CreatorCard />
</div>
</div>