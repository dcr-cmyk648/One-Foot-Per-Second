(function () {
	'use strict';
	if (!window.OFPS_PWA || window.OFPS_PWA.lifecycleSnapshot) return;

	const nowSeconds = function () { return Date.now() / 1000; };
	const lifecycle = {
		serial: 0,
		state: document.visibilityState === 'hidden' ? 'hidden' : 'visible',
		hiddenAt: document.visibilityState === 'hidden' ? nowSeconds() : 0,
		visibleAt: document.visibilityState === 'hidden' ? 0 : nowSeconds(),
		reason: 'load'
	};

	function recordLifecycle(nextState, reason) {
		const timestamp = nowSeconds();
		if (nextState === 'hidden') {
			if (lifecycle.state !== 'hidden') lifecycle.hiddenAt = timestamp;
		} else {
			lifecycle.visibleAt = timestamp;
		}
		lifecycle.state = nextState;
		lifecycle.reason = reason;
		lifecycle.serial += 1;
	}

	window.OFPS_PWA.lifecycleSnapshot = function () {
		return JSON.stringify(lifecycle);
	};

	document.addEventListener('visibilitychange', function () {
		recordLifecycle(document.visibilityState === 'hidden' ? 'hidden' : 'visible', 'visibilitychange');
	});
	window.addEventListener('pagehide', function () { recordLifecycle('hidden', 'pagehide'); });
	window.addEventListener('pageshow', function () { recordLifecycle('visible', 'pageshow'); });
	document.addEventListener('freeze', function () { recordLifecycle('hidden', 'freeze'); });
	document.addEventListener('resume', function () { recordLifecycle('visible', 'resume'); });
})();
