<script>
    import { apiFetch } from '$lib/api';
    import { onMount } from 'svelte';

    let creators = [];

    let newCreator = {
        name: '',
        username: '',
        real_name: '',
        nationality: '',
        age: '',
        about_me: '',
        profile_image: '',
        banner_image: '',
        theme_color: ''
    };

    let editingId = null;
    let edit = {};

    async function loadCreators() {
        const res = await apiFetch('http://localhost:4567/api/creators');
        const data = await res.json();
        creators = [...data];
    }

    onMount(loadCreators);

    async function addCreator() {
        const res = await apiFetch('http://localhost:4567/admin/creators', {
            method: 'POST',
            body: JSON.stringify(newCreator)
        });

        const data = await res.json();

        if (data.success) {
            creators = [...creators, data.creator];
            newCreator = {
                name: '',
                username: '',
                real_name: '',
                nationality: '',
                age: '',
                about_me: '',
                profile_image: '',
                banner_image: '',
                theme_color: ''
            };
        }
    }

    function startEdit(c) {
        editingId = c.id;
        edit = { ...c };
    }

    async function saveEdit(id) {
        const res = await apiFetch(`http://localhost:4567/admin/creators/${id}`, {
            method: 'PUT',
            body: JSON.stringify(edit)
        });

        const data = await res.json();

        if (data.success) {
            creators = creators.map(c =>
                c.id === id ? data.creator : c
            );

            editingId = null;
            edit = {};
        }
    }

    async function deleteCreator(id) {
        const res = await apiFetch(`http://localhost:4567/admin/creators/${id}`, {
            method: 'DELETE'
        });

        const data = await res.json();

        if (data.success) {
            creators = creators.filter(c => c.id !== id);
        }
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
    <input placeholder="Profile_Image" bind:value={newCreator.profile_image}>
    <input placeholder="Banner image" bind:value={newCreator.banner_image}>
    <input placeholder="Theme color" bind:value={newCreator.theme_color}>

    <button on:click={addCreator}>Add Creator</button>
</div>

<hr>

<!-- LIST -->
{#each creators as c (c.id)}
    <div style="border:1px solid #ccc; padding:10px; margin:10px 0;">

        {#if editingId === c.id}

            <input placeholder="Name" bind:value={edit.name}>
            <input placeholder="Username"bind:value={edit.username}>
            <input placeholder="Real name" bind:value={edit.real_name}>
            <input placeholder="Nationality" bind:value={edit.nationality}>
            <input placeholder="Age" type="number" bind:value={edit.age}>
            <input placeholder="About me" bind:value={edit.about_me}>
            <input placeholder="Profile_Image" bind:value={edit.profile_image}>
            <input placeholder="Banner_Image" bind:value={edit.banner_image}>
            <input placeholder="Theme Color" bind:value={edit.theme_color}>

            <button on:click={() => saveEdit(c.id)}>Save</button>

        {:else}

            <h3>{c.name}</h3>
            <p>@{c.username}</p>
            <p>{c.real_name}</p>
            <p>{c.nationality} </p>
            <p>{c.age}</p>
            <p>{c.about_me}</p>
            <p>Last updated: {c.updated_at}</p>

            <button on:click={() => startEdit(c)}>Edit</button>
            <button on:click={() => deleteCreator(c.id)}>Delete</button>

        {/if}
    </div>
{/each}