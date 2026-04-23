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

<h1>Creators</h1>

<!-- ADD NEW -->
<div>
    <input placeholder="Name" bind:value={newCreator.name}>
    <input placeholder="Username" bind:value={newCreator.username}>
    <input placeholder="Real name" bind:value={newCreator.real_name}>
    <input placeholder="Nationality" bind:value={newCreator.nationality}>
    <input placeholder="Age" type="number" bind:value={newCreator.age}>
    <input placeholder="About me" bind:value={newCreator.about_me}>
    <input placeholder="Profile image" bind:value={newCreator.profile_image}>
    <input placeholder="Banner image" bind:value={newCreator.banner_image}>
    <input placeholder="Theme color" bind:value={newCreator.theme_color}>
    <button on:click={addCreator}>Add Creator</button>
</div>

<hr>

{#each creators as c (c.id)}
    <div style="border:1px solid #ccc; padding:10px; margin:10px 0;">

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
            <p>@{c.username} — {c.nationality} — Age: {c.age}</p>
            <p>{c.about_me}</p>
            <p>Last updated: {c.updated_at}</p>

            <!-- CATEGORIES -->
            <div>
                <strong>Categories:</strong>
                {#each c.category_ids as catId}
                    {@const cat = categories.find(cat => cat.id == catId)}
                    {#if cat}
                        <span style="margin-right:6px;">
                            {cat.name}
                            <button on:click={() => removeCategory(c.id, catId)}>✕</button>
                        </span>
                    {/if}
                {/each}

                <select bind:value={selectedCategoryId[c.id]}>
                    <option value="">Add category...</option>
                    {#each categories.filter(cat => !c.category_ids.includes(cat.id)) as cat}
                        <option value={cat.id}>{cat.name}</option>
                    {/each}
                </select>
                <button on:click={() => addCategory(c.id)}>Add</button>
            </div>

            <button on:click={() => startEdit(c)}>Edit</button>
            <button on:click={() => deleteCreator(c.id)}>Delete</button>
        {/if}
    </div>
{/each}