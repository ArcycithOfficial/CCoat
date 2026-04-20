<script>
    import { apiFetch } from '$lib/api';
    import { onMount } from 'svelte';

    let categories = [];
    let newCategory = '';

    async function loadCategories() {
        const res = await apiFetch('http://localhost:4567/api/categories');
        categories = await res.json();
    }

    onMount(loadCategories);

    async function addCategory() {
        const res = await apiFetch('http://localhost:4567/admin/categories', {
            method: 'POST',
            body: JSON.stringify({ name: newCategory })
        });

        const data = await res.json();

        if (data.success) {
            await loadCategories();
            newCategory = '';
        }
    }

    function edit(cat) {
        editingId = cat.id;
        editValue = cat.name;
    }

    async function saveEdit(id) {
        const res = await apiFetch(`http://localhost:4567/admin/categories/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ name: editValue })
        });

        const data = await res.json();

        if (data.success) {
                await loadCategories();
                editingId = null;
                editValue = '';
            }
    }

    async function deleteCategory(id) {
        const res = await apiFetch(`http://localhost:4567/admin/categories/${id}`, {
            method: 'DELETE'
        });
        const data = await res.json();

        if (data.success) {
            await loadCategories();
        }
        
    }
</script>

<h1>Categories</h1>

<input bind:value={newCategory} placeholder="New category">
<button on:click={addCategory}>Add</button>

{#each categories as c}
    <div>
        {c.name}
        {#if editingId === c.id}
            <input bind:value={editValue} />
            <button on:click={() => saveEdit(c.id)}>Save</button>
        {:else}
            {c.name}
            <button on:click={() => edit(c)}>Edit</button>
            <button on:click={() => deleteCategory(c.id)}>Delete</button>
        {/if}
    </div>
{/each}