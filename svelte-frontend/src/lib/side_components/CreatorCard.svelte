<script>
	export let creator;
</script>

<a href="/creators/{creator.id}" class="creator-card">
	<div class="overflow-hidden rounded-md outline-2">
		<div class="h-32 bg-gradient-to-br from-neutral-800 to-violet-950 sm:h-40">
			{#if creator.profile_image}
				<img
					src={creator.profile_image}
					alt={creator.name}
					class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
				/>
			{:else}
				<div
					class="flex h-full w-full items-center justify-center text-4xl font-bold text-neutral-600"
				>
					{creator.name?.[0]?.toUpperCase() ?? '?'}
				</div>
			{/if}
		</div>
		<div class="flex items-center flex-col gap-1 outline-2 py-1 bg-gradient-to-br from-black to-violet-950">
			<p class="text-sm font-semibold text-neutral-100 truncate">{creator.name}</p>
			{#if creator.category_names}
				<div class=" flex flex-wrap gap-1">
					{#each creator.category_names.split(',') as cat}
						<span
							class="outline border-neutral-700 bg-neutral-800 px-2 py-0.5 text-[7px] font-bold tracking-wide text-neutral-400 uppercase"
						>
							{cat.trim()}
						</span>
					{/each}
				</div>
			{/if}
		</div>
	</div>
</a>
