<script>
  	import Navbar from '$lib/side_components/Nav.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import './layout.css';
	let { children } = $props();
</script>
<Navbar />
{@render children()}
<Footer />
