
<script>
import { onMount } from 'svelte';
  let creators = [];

  onMount(async () => {
    const res = await fetch('http://localhost:4567/api/creators');
    creators = await res.json();
  });
</script>
  {#each creators as creator}
     <a href="/creators/{creator.id}" class="creator-card">
        <div class="border rounded-md">
        <img class="object-cover border h-20" src="{creator.profile_image}" alt="{creator.name}" />
        <div class="border flex items-center gap-2">
        <h2 class="flex-1">{creator.name}</h2>
        <img class="h-4 w-4" src="/images/cart" alt="card-icon" />
        <img class="h-4 w-4" src="/images/heart" alt="heart-icon" />
        </div>
        </div>
     </a>

    <a href="/creators/{creator.id}" class="creator-card">
        <div class="border rounded-md">
        <img class="object-cover border h-20" src="{creator.profile_image}" alt="{creator.name}" />
        <div class="border">
        <h2>{creator.name}</h2>
        </div>
        </div>
     </a>

          <a href="/creators/{creator.id}" class="creator-card">
        <div class="border rounded-md">
        <img class="object-cover border h-20" src="{creator.profile_image}" alt="{creator.name}" />
        <div class="border">
        <h2>{creator.name}</h2>
        </div>
        </div>
     </a>

  {/each}
