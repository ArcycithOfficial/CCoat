import { get } from 'svelte/store';
import { csrf } from '$lib/stores';

export async function apiFetch(url, options = {}) {
    const token = get(csrf);

    const headers = {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token,
        ...(options.headers || {})
    };

    return fetch(url, {
        ...options,
        credentials: 'include',
        headers
    });
}