<script>
    import { onMount } from 'svelte';

    let categories = [];
    let newCategory = '';

    onMount(async () => {
        const res = await fetch('http://localhost:4567/api/categories', {
            credentials: 'include'
        });

        categories = await res.json();
    });

    async function addCategory() {
        const res = await fetch('http://localhost:4567/admin/categories', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ name: newCategory })
        });

        const data = await res.json();

        if (data.success) {
            categories.push({ name: newCategory });
            newCategory = '';
        }
    }

    async function deleteCategory(id) {
        await fetch(`http://localhost:4567/admin/categories/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        categories = categories.filter(c => c.id !== id);
    }
</script>

<h1>Categories</h1>

<input bind:value={newCategory} placeholder="New category">
<button on:click={addCategory}>Add</button>

{#each categories as c}
    <div>
        {c.name}
        <button on:click={() => deleteCategory(c.id)}>Delete</button>
    </div>
{/each}