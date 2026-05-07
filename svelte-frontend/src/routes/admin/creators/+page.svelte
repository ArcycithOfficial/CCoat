<script>
    import { apiFetch } from '$lib/api';
    import { onMount } from 'svelte';

    let creators = [];
    let categories = [];
    let selectedCategoryId = {};  // { [creatorId]: categoryId }

    let newCreator = {
        name: '', username: '', real_name: '', nationality: '',
        age: '', about_me: '', profile_image: '', banner_image: '', theme_color: ''
    };

    let editingId = null;
    let edit = {};

    async function loadCreators() {
        const res = await apiFetch('http://localhost:4567/api/creators');
        const data = await res.json();
        creators = data.map(c => ({
            ...c,
            category_ids: JSON.parse(c.category_ids || '[]')
        }));
    }

    async function loadCategories() {
        const res = await apiFetch('http://localhost:4567/api/categories');
        categories = await res.json();
    }

    onMount(() => {
        loadCreators();
        loadCategories();
    });

    async function addCategory(creatorId) {
        const catId = selectedCategoryId[creatorId];
        if (!catId) return;

        await apiFetch(`http://localhost:4567/admin/creators/${creatorId}/categories`, {
            method: 'POST',
            body: JSON.stringify({ category_id: catId })
        });

        await loadCreators();
    }

    async function removeCategory(creatorId, catId) {
        await apiFetch(`http://localhost:4567/admin/creators/${creatorId}/categories/${catId}`, {
            method: 'DELETE'
        });

        await loadCreators();
    }

    async function addCreator() {
        const res = await apiFetch('http://localhost:4567/admin/creators', {
            method: 'POST',
            body: JSON.stringify(newCreator)
        });
        const data = await res.json();
        if (data.success) {
            creators = [...creators, { ...data.creator, category_ids: [] }];
            newCreator = { name: '', username: '', real_name: '', nationality: '', age: '', about_me: '', profile_image: '', banner_image: '', theme_color: '' };
        }
    }

    function startEdit(c) { editingId = c.id; edit = { ...c }; }

    async function saveEdit(id) {
        const res = await apiFetch(`http://localhost:4567/admin/creators/${id}`, {
            method: 'PUT',
            body: JSON.stringify(edit)
        });
        const data = await res.json();
        if (data.success) {
            creators = creators.map(c => c.id === id ? { ...data.creator, category_ids: c.category_ids } : c);
            editingId = null; edit = {};
        }
    }

    async function deleteCreator(id) {
        const res = await apiFetch(`http://localhost:4567/admin/creators/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if (data.success) creators = creators.filter(c => c.id !== id);
    }
</script>



<section class="bg-purple-900 text-white">
<h1 class="text-center font-bold capitalize text-2xl mb-1">Creators</h1>
<!-- ADD NEW -->
<div class="flex-col columns-2 px-2 gap-2">
    <input placeholder="Name" bind:value={newCreator.name} class="w-full">
    <input placeholder="Username" bind:value={newCreator.username} class="w-full">
    <input placeholder="Real name" bind:value={newCreator.real_name} class="w-full">
    <input placeholder="Nationality" bind:value={newCreator.nationality} class="w-full">
    <input placeholder="Age" type="number" class="w-full" bind:value={newCreator.age}>
    <input placeholder="About me" bind:value={newCreator.about_me} class="w-full">
    <input placeholder="Profile image" bind:value={newCreator.profile_image} class="w-full">
    <input placeholder="Banner image" bind:value={newCreator.banner_image} class="w-full">
    <input placeholder="Theme color" bind:value={newCreator.theme_color} class="w-full">
    <button on:click={addCreator} class="w-full outline-neutral-700 outline-2 bg-green-500 text-black font-medium">Add Creator</button>
</div>

<hr>

{#each creators as c (c.id)}
    <div class="border-black border p-10">
        <div class="bg-purple-950 outline-2 p-2 outline-black rounded">
        {#if editingId === c.id}
            <input placeholder="Name" bind:value={edit.name}>
            <input placeholder="Username" bind:value={edit.username}>
            <input placeholder="Real name" bind:value={edit.real_name}>
            <input placeholder="Nationality" bind:value={edit.nationality}>
            <input placeholder="Age" type="number" bind:value={edit.age}>
            <input placeholder="About me" bind:value={edit.about_me}>
            <input placeholder="Profile image" bind:value={edit.profile_image}>
            <input placeholder="Banner image" bind:value={edit.banner_image}>
            <input placeholder="Theme color" bind:value={edit.theme_color}>
            <button on:click={() => saveEdit(c.id)}>Save</button>
        {:else}

            <h3>{c.name}</h3>
            <p>Username: @{c.username ?? 'Unknown...'}</p>
            <p>Nationality: {c.nationality ?? 'Unknown...'}</p>
            <p>Age: {c.age ?? 'Unknown...'}</p>
            <p>Full Bio: {c.about_me ?? 'Unknown...'}</p>

            <hr>
            <!-- CATEGORIES -->
            <div>
                <h2>Categories:</h2>
                <div class="flex flex-wrap gap-2 py-2">
                {#each c.category_ids as catId}
                    {@const cat = categories.find(cat => cat.id == catId)}
                    {#if cat}
                        <div class="outline rounded px-1">
                            {cat.name}
                            <button on:click={() => removeCategory(c.id, catId)}>✕</button>
                        </div>
                    {/if}
                {/each}
                </div>


                <select bind:value={selectedCategoryId[c.id]} class="bg-black">
                    <option value="">Add category...</option>
                    {#each categories.filter(cat => !c.category_ids.includes(cat.id)) as cat}
                        <option value={cat.id}>{cat.name}</option>
                    {/each}
                </select>
                <button on:click={() => addCategory(c.id)}>Add</button>
            </div>
            <p>Last updated: {c.updated_at}</p>

            <button on:click={() => startEdit(c)} class="outline-2 bg-orange-400 px-2 rounded outline-black">Edit</button>
            <button on:click={() => deleteCreator(c.id)} class="outline-2 outline-black px-2 rounded bg-red-600">Delete</button>
        {/if}
        </div>
    </div>
{/each}
</section>