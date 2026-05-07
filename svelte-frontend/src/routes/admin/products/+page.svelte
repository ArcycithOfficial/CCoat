<script>
  import { apiFetch } from '$lib/api';
  import { onMount } from 'svelte';

  let creators = [];
  let products = [];
  let optionTypes = [];
  let allOptionValues = {};
  let productOptionValues = {};
  let selectedCreatorId = '';
  let showOptionsManager = false;
  let newTypeName = '';
  let newValueInputs = {};

  let newProduct = { name: '', description: '', base_price: '', image: '' };
  let editingId = null;
  let edit = {};

  onMount(async () => {
    const [creatorsRes, optionsRes] = await Promise.all([
      apiFetch('http://localhost:4567/api/creators'),
      apiFetch('http://localhost:4567/api/option_types')
    ]);
    creators = await creatorsRes.json();
    optionTypes = await optionsRes.json();

    for (const type of optionTypes) {
      const res = await apiFetch(`http://localhost:4567/api/option_types/${type.id}/values`);
      allOptionValues[type.id] = await res.json();
      newValueInputs[type.id] = { value: '', price_modifier: 0 };
    }
  });

  async function reloadOptionTypes() {
    const res = await apiFetch('http://localhost:4567/api/option_types');
    optionTypes = await res.json();
    for (const type of optionTypes) {
      const r = await apiFetch(`http://localhost:4567/api/option_types/${type.id}/values`);
      allOptionValues[type.id] = await r.json();
      if (!newValueInputs[type.id]) newValueInputs[type.id] = { value: '', price_modifier: 0 };
    }
    allOptionValues = { ...allOptionValues };
  }

  async function addType() {
    if (!newTypeName) return;
    await apiFetch('http://localhost:4567/admin/option_types', {
      method: 'POST',
      body: JSON.stringify({ name: newTypeName })
    });
    newTypeName = '';
    await reloadOptionTypes();
  }

  async function deleteType(id) {
    await apiFetch(`http://localhost:4567/admin/option_types/${id}`, { method: 'DELETE' });
    await reloadOptionTypes();
  }

  async function addValue(typeId) {
    const input = newValueInputs[typeId];
    if (!input?.value) return;
    await apiFetch(`http://localhost:4567/admin/option_types/${typeId}/values`, {
      method: 'POST',
      body: JSON.stringify({ value: input.value, price_modifier: input.price_modifier || 0 })
    });
    newValueInputs[typeId] = { value: '', price_modifier: 0 };
    const res = await apiFetch(`http://localhost:4567/api/option_types/${typeId}/values`);
    allOptionValues[typeId] = await res.json();
    allOptionValues = { ...allOptionValues };
  }

  async function deleteValue(typeId, valueId) {
    await apiFetch(`http://localhost:4567/admin/option_values/${valueId}`, { method: 'DELETE' });
    allOptionValues[typeId] = allOptionValues[typeId].filter(v => v.id !== valueId);
    allOptionValues = { ...allOptionValues };
  }

  async function loadProducts(creatorId) {
    const res = await apiFetch(`http://localhost:4567/api/creators/${creatorId}/products`);
    products = await res.json();
    for (const p of products) {
      const res = await apiFetch(`http://localhost:4567/api/products/${p.id}/option_values`);
      const vals = await res.json();
      productOptionValues[p.id] = vals.map(v => v.id);
    }
    productOptionValues = { ...productOptionValues };
  }

  async function addProduct() {
    if (!selectedCreatorId) return;
    const res = await apiFetch(`http://localhost:4567/admin/creators/${selectedCreatorId}/products`, {
      method: 'POST',
      body: JSON.stringify(newProduct)
    });
    const data = await res.json();
    if (data.success) {
      await loadProducts(selectedCreatorId);
      newProduct = { name: '', description: '', base_price: '', image: '' };
    }
  }

  function startEdit(p) { editingId = p.id; edit = { ...p }; }

  async function saveEdit(id) {
    const res = await apiFetch(`http://localhost:4567/admin/products/${id}`, {
      method: 'PUT',
      body: JSON.stringify(edit)
    });
    const data = await res.json();
    if (data.success) {
      await loadProducts(selectedCreatorId);
      editingId = null;
    }
  }

  async function deleteProduct(id) {
    const res = await apiFetch(`http://localhost:4567/admin/products/${id}`, { method: 'DELETE' });
    const data = await res.json();
    if (data.success) await loadProducts(selectedCreatorId);
  }

  async function toggleOptionValue(productId, optionValueId) {
    const hasIt = productOptionValues[productId]?.includes(optionValueId);
    if (hasIt) {
      await apiFetch(`http://localhost:4567/admin/products/${productId}/option_values/${optionValueId}`, { method: 'DELETE' });
      productOptionValues[productId] = productOptionValues[productId].filter(id => id !== optionValueId);
    } else {
      await apiFetch(`http://localhost:4567/admin/products/${productId}/option_values`, {
        method: 'POST',
        body: JSON.stringify({ option_value_id: optionValueId })
      });
      productOptionValues[productId] = [...(productOptionValues[productId] || []), optionValueId];
    }
    productOptionValues = { ...productOptionValues };
  }
</script>

<section class="text-white p-10">
  <h1 class="text-2xl font-bold mb-4">Products</h1>

  <!-- OPTIONS MANAGER toggle -->
  <button on:click={() => showOptionsManager = !showOptionsManager}
    class="bg-purple-800 px-4 py-2 rounded mb-6 text-sm">
    {showOptionsManager ? '▲ Hide Options Manager' : '▼ Manage Option Types & Values'}
  </button>

  {#if showOptionsManager}
    <div class="bg-purple-950 p-6 rounded-lg mb-6">
      <h2 class="font-bold mb-4">Option Types & Values</h2>

      <div class="flex gap-2 mb-6">
        <input bind:value={newTypeName} placeholder="New type e.g. Color, Size"
          class="bg-purple-900 p-2 rounded flex-1"/>
        <button on:click={addType} class="bg-green-700 px-4 py-2 rounded w-fit">Add Type</button>
      </div>

      {#each optionTypes as type}
        <div class="bg-purple-900 p-4 rounded-lg mb-3">
          <div class="flex justify-between items-center mb-2">
            <h3 class="font-bold">{type.name}</h3>
            <button on:click={() => deleteType(type.id)}
              class="bg-red-600 px-2 py-1 rounded text-xs">Delete type</button>
          </div>

          <div class="flex flex-wrap gap-1 mb-3">
            {#each allOptionValues[type.id] || [] as val}
              <div class="flex items-center gap-1 bg-purple-800 px-2 py-1 rounded text-xs">
                {val.value}
                {#if val.price_modifier > 0}
                  <span class="text-green-300">+${val.price_modifier}</span>
                {/if}
                <button on:click={() => deleteValue(type.id, val.id)}
                  class="text-red-400 ml-1 hover:text-red-200">✕</button>
              </div>
            {/each}
          </div>

          <div class="flex gap-2">
            <input
              bind:value={newValueInputs[type.id].value}
              placeholder="e.g. Red, XL"
              class="bg-purple-800 p-1 rounded flex-1 text-sm"
            />
            <input
              type="number"
              bind:value={newValueInputs[type.id].price_modifier}
              placeholder="+price"
              class="bg-purple-800 p-1 rounded w-16 text-sm"
            />
            <button on:click={() => addValue(type.id)}
              class="bg-green-700 px-3 py-1 rounded text-sm w-fit">Add</button>
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <select bind:value={selectedCreatorId} on:change={() => loadProducts(selectedCreatorId)}
    class="bg-purple-900 p-2 rounded mb-6">
    <option value="">Select creator...</option>
    {#each creators as c}
      <option value={c.id}>{c.name}</option>
    {/each}
  </select>

  {#if selectedCreatorId}
    <div class="bg-purple-950 p-6 rounded-lg mb-6">
      <h2 class="font-bold mb-3">Add Product</h2>
      <div class="flex flex-col gap-2">
        <input bind:value={newProduct.name} placeholder="Name" class="bg-purple-900 p-2 rounded"/>
        <input bind:value={newProduct.description} placeholder="Description" class="bg-purple-900 p-2 rounded"/>
        <input bind:value={newProduct.base_price} placeholder="Price" type="number" class="bg-purple-900 p-2 rounded"/>
        <input bind:value={newProduct.image} placeholder="Image URL" class="bg-purple-900 p-2 rounded"/>
        <button on:click={addProduct} class="bg-green-700 px-4 py-2 rounded w-fit">Add Product</button>
      </div>
    </div>

    {#each products as p}
      <div class="bg-purple-950 p-4 rounded-lg mb-4">
        {#if editingId === p.id}
          <input bind:value={edit.name} class="bg-purple-900 p-1 rounded w-full mb-2"/>
          <input bind:value={edit.description} class="bg-purple-900 p-1 rounded w-full mb-2"/>
          <input bind:value={edit.base_price} type="number" class="bg-purple-900 p-1 rounded w-full mb-2"/>
          <input bind:value={edit.image} class="bg-purple-900 p-1 rounded w-full mb-2"/>
          <button on:click={() => saveEdit(p.id)} class="bg-blue-600 px-3 py-1 rounded">Save</button>
        {:else}
          <h3 class="font-bold text-lg">{p.name}</h3>
          <p class="text-sm text-gray-400 mb-1">{p.description}</p>
          <p class="text-sm mb-3">${p.base_price}</p>

          <div class="mb-3">
            <p class="text-xs text-gray-400 mb-2">Available options:</p>
            {#each optionTypes as type}
              {#if allOptionValues[type.id]?.length > 0}
                <div class="mb-2">
                  <p class="text-xs text-gray-500 mb-1">{type.name}</p>
                  <div class="flex flex-wrap gap-1">
                    {#each allOptionValues[type.id] as val}
                      {@const hasIt = productOptionValues[p.id]?.includes(val.id)}
                      <button
                        on:click={() => toggleOptionValue(p.id, val.id)}
                        class="px-2 py-1 rounded text-xs transition-colors
                          {hasIt ? 'bg-purple-600 outline outline-1 outline-white' : 'bg-gray-700'}"
                      >
                        {val.value}
                        {#if val.price_modifier > 0}
                          <span class="text-green-300">+${val.price_modifier}</span>
                        {/if}
                      </button>
                    {/each}
                  </div>
                </div>
              {/if}
            {/each}
          </div>

          <div class="flex gap-2">
            <button on:click={() => startEdit(p)} class="bg-orange-500 px-3 py-1 rounded text-sm">Edit</button>
            <button on:click={() => deleteProduct(p.id)} class="bg-red-600 px-3 py-1 rounded text-sm">Delete</button>
          </div>
        {/if}
      </div>
    {/each}
  {/if}
</section>