
<script>
  export let creator;
</script>

     <a href="/creators/{creator.id}" class="creator-card">
        <div class="border rounded-md">
        <img class="object-cover border w-full" src="{creator.profile_image}" alt="{creator.name}" />
        <div class="border flex items-center gap-1">
        <h1 class="flex-1 font-serif text-xs">@{creator.name}</h1>
        <img class="h-10 w-10 center" src="/images/cart.png" alt="cart-icon" />
        <img class="h-10 w-10 center" src="/images/heart.png" alt="heart-icon" />
        </div>
        </div>
     </a>
   

