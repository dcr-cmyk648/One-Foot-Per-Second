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

	// Godot's stock PWA updater asks the waiting worker to activate and expects
	// Client.navigate() to reload every open tab. iOS Home Screen apps sometimes
	// complete the activation without honoring that navigation, leaving the game
	// on its disabled "Saving your run" banner forever. Listen for the controller
	// handoff and keep a bounded location.reload() fallback on the page itself.
	let updateReloadStarted = false;
	window.OFPS_PWA.activateWaitingUpdate = function () {
		if (!('serviceWorker' in navigator)) return false;
		if (updateReloadStarted) return true;
		updateReloadStarted = true;
		let reloadRequested = false;
		const reloadOnce = function () {
			if (reloadRequested) return;
			reloadRequested = true;
			window.location.reload();
		};
		const askWorkerToActivate = function (registration) {
			if (!registration) {
				setTimeout(reloadOnce, 100);
				return;
			}
			const waiting = registration.waiting;
			if (waiting) {
				try {
					waiting.postMessage('update');
				} catch (error) {
					setTimeout(reloadOnce, 100);
				}
				return;
			}
			if (registration.installing) {
				registration.installing.addEventListener('statechange', function () {
					if (registration.waiting) askWorkerToActivate(registration);
				});
				return;
			}
			registration.update().then(function () {
				if (registration.waiting) askWorkerToActivate(registration);
				else setTimeout(reloadOnce, 250);
			}).catch(function () { setTimeout(reloadOnce, 100); });
		};
		navigator.serviceWorker.addEventListener(
			'controllerchange',
			function () { setTimeout(reloadOnce, 50); },
			{ once: true }
		);
		navigator.serviceWorker.getRegistration().then(askWorkerToActivate).catch(function () {
			setTimeout(reloadOnce, 100);
		});
		setTimeout(reloadOnce, 4500);
		return true;
	};
	window.OFPS_PWA.forceUpdateReload = function () {
		window.location.reload();
		return true;
	};

	document.addEventListener('visibilitychange', function () {
		recordLifecycle(document.visibilityState === 'hidden' ? 'hidden' : 'visible', 'visibilitychange');
	});
	window.addEventListener('pagehide', function () { recordLifecycle('hidden', 'pagehide'); });
	window.addEventListener('pageshow', function () { recordLifecycle('visible', 'pageshow'); });
	document.addEventListener('freeze', function () { recordLifecycle('hidden', 'freeze'); });
	document.addEventListener('resume', function () { recordLifecycle('visible', 'resume'); });
})();
