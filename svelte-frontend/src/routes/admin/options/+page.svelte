<script>
  import { apiFetch } from '$lib/api';
  import { onMount } from 'svelte';

  let optionTypes = [];
  let newTypeName = '';
  let selectedType = null;
  let values = [];
  let newValue = { value: '', price_modifier: 0 };
  let editingValueId = null;
  let editValue = {};

  onMount(loadTypes);

  async function loadTypes() {
    const res = await apiFetch('http://localhost:4567/api/option_types');
    optionTypes = await res.json();
  }

  async function addType() {
    if (!newTypeName) return;
    const res = await apiFetch('http://localhost:4567/admin/option_types', {
      method: 'POST',
      body: JSON.stringify({ name: newTypeName })
    });
    const data = await res.json();
    if (data.success) {
      await loadTypes();
      newTypeName = '';
    }
  }

  async function deleteType(id) {
    await apiFetch(`http://localhost:4567/admin/option_types/${id}`, { method: 'DELETE' });
    if (selectedType?.id === id) { selectedType = null; values = []; }
    await loadTypes();
  }

  async function selectType(type) {
    selectedType = type;
    await loadValues(type.id);
  }

  async function loadValues(typeId) {
    const res = await apiFetch(`http://localhost:4567/api/option_types/${typeId}/values`);
    values = await res.json();
  }

  async function addValue() {
    if (!newValue.value) return;
    await apiFetch(`http://localhost:4567/admin/option_types/${selectedType.id}/values`, {
      method: 'POST',
      body: JSON.stringify(newValue)
    });
    await loadValues(selectedType.id);
    newValue = { value: '', price_modifier: 0 };
  }

  function startEditValue(v) {
    editingValueId = v.id;
    editValue = { ...v };
  }

  async function saveEditValue(id) {
    await apiFetch(`http://localhost:4567/admin/option_values/${id}`, {
      method: 'PUT',
      body: JSON.stringify(editValue)
    });
    await loadValues(selectedType.id);
    editingValueId = null;
  }

  async function deleteValue(id) {
    await apiFetch(`http://localhost:4567/admin/option_values/${id}`, { method: 'DELETE' });
    await loadValues(selectedType.id);
  }
</script>

<section class="text-white p-10">
  <h1 class="text-2xl font-bold mb-6">Options</h1>

  <div class="grid grid-cols-2 gap-6">
    <!-- VÄNSTER: option types -->
    <div class="bg-purple-950 p-6 rounded-lg">
      <h2 class="font-bold mb-4">Option Types</h2>
      <div class="flex gap-2 mb-4">
        <input bind:value={newTypeName} placeholder="e.g. Color, Size..."
          class="bg-purple-900 p-2 rounded flex-1"/>
        <button on:click={addType} class="bg-green-700 px-4 py-2 rounded w-fit">Add</button>
      </div>

      {#each optionTypes as type}
        <div class="flex justify-between items-center p-2 rounded mb-2
          {selectedType?.id === type.id ? 'bg-purple-700' : 'bg-purple-900'}">
          <button on:click={() => selectType(type)} class="flex-1 text-left">
            {type.name}
          </button>
          <button on:click={() => deleteType(type.id)}
            class="bg-red-600 px-2 py-1 rounded text-xs ml-2">Delete</button>
        </div>
      {/each}
    </div>

    <!-- HÖGER: values för vald type -->
    <div class="bg-purple-950 p-6 rounded-lg">
      {#if selectedType}
        <h2 class="font-bold mb-4">Values for: {selectedType.name}</h2>

        <div class="flex gap-2 mb-4">
          <input bind:value={newValue.value} placeholder="e.g. Red, XL..."
            class="bg-purple-900 p-2 rounded flex-1"/>
          <input bind:value={newValue.price_modifier} type="number" placeholder="+price"
            class="bg-purple-900 p-2 rounded w-20"/>
          <button on:click={addValue} class="bg-green-700 px-4 py-2 rounded w-fit">Add</button>
        </div>

        {#each values as v}
          <div class="bg-purple-900 p-3 rounded mb-2">
            {#if editingValueId === v.id}
              <div class="flex gap-2">
                <input bind:value={editValue.value} class="bg-purple-800 p-1 rounded flex-1"/>
                <input bind:value={editValue.price_modifier} type="number" class="bg-purple-800 p-1 rounded w-20"/>
                <button on:click={() => saveEditValue(v.id)} class="bg-blue-600 px-3 py-1 rounded text-sm">Save</button>
              </div>
            {:else}
              <div class="flex justify-between items-center">
                <div>
                  <span class="font-medium">{v.value}</span>
                  {#if v.price_modifier > 0}
                    <span class="text-green-400 text-xs ml-2">+${v.price_modifier}</span>
                  {/if}
                </div>
                <div class="flex gap-2">
                  <button on:click={() => startEditValue(v)} class="bg-orange-500 px-2 py-1 rounded text-xs">Edit</button>
                  <button on:click={() => deleteValue(v.id)} class="bg-red-600 px-2 py-1 rounded text-xs">Delete</button>
                </div>
              </div>
            {/if}
          </div>
        {/each}
      {:else}
        <p class="text-gray-500">Select an option type to see its values</p>
      {/if}
    </div>
  </div>
</section>