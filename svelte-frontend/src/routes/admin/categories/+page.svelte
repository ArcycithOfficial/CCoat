<script>
    import { apiFetch } from '$lib/api';
    import { onMount } from 'svelte';

    let categories = [];
    let newCategory = '';

    let editingId = null;
    let editValue = '';

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


<section class="text-white align-middle flex justify-center">
<div class="bg-purple-950 w-100">
<h1 class="text-center font-bold">Categories</h1>

<div class="justify-center flex flex-col">
<input bind:value={newCategory} placeholder="New category" class="w-[80%] m-auto">
<button on:click={addCategory} class="bg-green-700 outline-2 outline-black w-fit mx-auto my-2 px-3">Add</button>
</div>

{#each categories as c}
    <div class="m-2">
        {#if editingId === c.id}
            <input bind:value={editValue} />
            <button on:click={() => saveEdit(c.id)}>Save</button>
        {:else}
            {c.name}
            <button on:click={() => edit(c)} class="bg-yellow-500 px-2">Edit</button>
            <button on:click={() => deleteCategory(c.id)} class="bg-red-600 px-2">Delete</button>
        {/if}
    </div>
{/each}
</div>
</section>