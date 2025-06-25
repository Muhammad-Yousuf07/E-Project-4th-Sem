'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "32be40abf44cd4e562d0446d7631bb68",
"assets/AssetManifest.bin.json": "d8b678841c48dc57f53cae16ebdda876",
"assets/AssetManifest.json": "898d3d69e211bdbb766e2e93fb975736",
"assets/assets/fonts/poppins/Poppins-Black.ttf": "14d00dab1f6802e787183ecab5cce85e",
"assets/assets/fonts/poppins/Poppins-Bold.ttf": "08c20a487911694291bd8c5de41315ad",
"assets/assets/fonts/poppins/Poppins-ExtraBold.ttf": "d45bdbc2d4a98c1ecb17821a1dbbd3a4",
"assets/assets/fonts/poppins/Poppins-Medium.ttf": "bf59c687bc6d3a70204d3944082c5cc0",
"assets/assets/fonts/poppins/Poppins-Regular.ttf": "093ee89be9ede30383f39a899c485a82",
"assets/assets/fonts/poppins/Poppins-SemiBold.ttf": "6f1520d107205975713ba09df778f93f",
"assets/assets/icons/arrow_right.svg": "7d2e92d8f069ee2c73f1820beea62dfd",
"assets/assets/icons/Back%2520ICon.svg": "a1540761ddc4d5ebd1ebf7e732a7af0a",
"assets/assets/icons/Bell.svg": "03c0fc05f0c26d3107496511ef140dd2",
"assets/assets/icons/Bill%2520Icon.svg": "ba05924f328f84b66a97e52a3c4998f2",
"assets/assets/icons/Call.svg": "52af54660badff2b15a84fd34203c7ee",
"assets/assets/icons/Camera%2520Icon.svg": "25207a856bce06a7c1f4d695638a0383",
"assets/assets/icons/Cart%2520Icon.svg": "8f7bf4c1e521fa6fd33da4793d5efbee",
"assets/assets/icons/Cash.svg": "9a1bfa4f03729b332bb98439f713637e",
"assets/assets/icons/Chat%2520bubble%2520Icon.svg": "3e6e1ab6925d3db86ce9bd109c121db0",
"assets/assets/icons/Check%2520mark%2520rounde.svg": "e83caa6ca41e8af9229ae29d79f9410b",
"assets/assets/icons/Close.svg": "70478a15e0479750b0b03e000041e9f3",
"assets/assets/icons/Conversation.svg": "291fb6c6acdeb807afb452ae90f930db",
"assets/assets/icons/Discover.svg": "250d05a15d5309cf9c7bd74a9cbf703a",
"assets/assets/icons/Error.svg": "0f876e9b9170982e37bbf767c6ebb47f",
"assets/assets/icons/facebook-2.svg": "48bf15d2057966765f384827997a2f41",
"assets/assets/icons/Flash%2520Icon.svg": "56a092e22e7e7b52b87750e159f4349c",
"assets/assets/icons/Game%2520Icon.svg": "272c7554e9c4500b098dbeee6f69f7fe",
"assets/assets/icons/Gift%2520Icon.svg": "bb408ed957fd0402eed3e718337f5438",
"assets/assets/icons/google-icon.svg": "38e282dafbaaf9823263d49349670447",
"assets/assets/icons/Heart%2520Icon.svg": "ce0d200430117b4e529679ba103cf4dd",
"assets/assets/icons/Heart%2520Icon_2.svg": "f728c6b3d75dfab6450f56a2a57633f0",
"assets/assets/icons/Location%2520point.svg": "146ea387710fa420046c0f71b89ad474",
"assets/assets/icons/Lock.svg": "44a5fb6d11a48fd52c87d95e34e7a689",
"assets/assets/icons/Log%2520out.svg": "ef8dc3d612e3e63ae4728a24d9982f13",
"assets/assets/icons/Mail.svg": "6b876f2539a1946b1a946e7a5646e909",
"assets/assets/icons/Parcel.svg": "3d49c2e94aa3e62e25a300b967381fed",
"assets/assets/icons/Phone.svg": "589731a88a098c9c6d40e32bc11c3d83",
"assets/assets/icons/Plus%2520Icon.svg": "23bd873f0fdef239500d68a150f9fa93",
"assets/assets/icons/Question%2520mark.svg": "7d0f74b3eb3cbeac772cb6a41476cfcf",
"assets/assets/icons/receipt.svg": "e0ecaf4c17597903fa1e8ab3c28fa963",
"assets/assets/icons/remove.svg": "77f17bcf86cb62db1b3ce224d6cb6fd3",
"assets/assets/icons/Search%2520Icon.svg": "5383aff67a0cc61bc20b953c73d87469",
"assets/assets/icons/Settings.svg": "d8fd4b8ed70a516c17d3d981d9a49999",
"assets/assets/icons/Shop%2520Icon.svg": "1eda40840728635d3279f313774d1675",
"assets/assets/icons/Star%2520Icon.svg": "1ef6ad3bbe15947a5b4d9bf153101fd3",
"assets/assets/icons/Success.svg": "b0a226cdd68878cf33bddc8d9d2cc1f6",
"assets/assets/icons/Trash.svg": "f877c275194b39ca5f21fe7202ca852a",
"assets/assets/icons/twitter.svg": "2186bb91925602b76e5a4384b2198c06",
"assets/assets/icons/User%2520Icon.svg": "950d2f1652bdb59675231707a9124535",
"assets/assets/icons/User.svg": "737d49c1953f8098f618d523b45e5657",
"assets/assets/images/avatar.jpg": "900defff42a1c164de4a1a0cf124e129",
"assets/assets/images/banner.gif": "73560203820283617ea62db7e612fad7",
"assets/assets/images/banner_1.png": "a8a7e512c57d629b20b30d1ba29437bb",
"assets/assets/images/banner_2.png": "fe65d2ad75c27b2a5d1b8de5f6406b24",
"assets/assets/images/user_avatar.png": "60be3eebb4c5a00b8b2696b0cb6ca9bc",
"assets/assets/images/watch1.png": "532ef76b3a1938fe614c511aba0efe59",
"assets/assets/images/watch2.webp": "19f0d7296cacfccd9c9a192484218e58",
"assets/assets/images/watch3.webp": "5ad88213b03cd1b6c7e910aa859ad6ac",
"assets/assets/images/watch4.webp": "db8999634acb794fd16206a956aa1ac4",
"assets/assets/images/watch5.png": "5310f21130ec36f75d8c04198992f740",
"assets/assets/images/watch_bg_1.jpg": "d0bc51d0da129c6c2a1f5b395796ad04",
"assets/assets/images/watch_bg_2.jpg": "04b08e7c3763d0d1cbe1b22276b2f973",
"assets/assets/images/watch_bg_3.jpg": "8b07db7e9e2a43e05044870dac57eb05",
"assets/assets/images/watch_bg_4.jpg": "31fc980a19abc858b5ac15ac2fe0c4da",
"assets/assets/images/watch_bg_5.jpg": "2e9bbabaf26af05e9db3b606f5732806",
"assets/assets/videos/home_banner_2.mp4": "f850345673d9def91c227236deb49786",
"assets/assets/videos/home_banner_3.mp4": "b873a28a0addc023af1e13ea03234ff4",
"assets/assets/videos/home_banner_4.mp4": "746935dc6200509e0b546f3baaa98700",
"assets/FontManifest.json": "e445941a33da2621ee7e58414f02b25c",
"assets/fonts/MaterialIcons-Regular.otf": "be580dab3d3e71fd157c901d5a64a689",
"assets/NOTICES": "7d4474f0057fa662955aa1ab4a0d239d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "73099e9bcd4ce22f34727db1aa14d7cc",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d1c8ee32a73a9d107a7ccf17e9966e53",
"/": "d1c8ee32a73a9d107a7ccf17e9966e53",
"main.dart.js": "aef91ee636dcf4c2e2797f6ae5e4d00f",
"manifest.json": "8a505a33c62beb8a26b873e5c6c56ffe",
"version.json": "54295459d0976636891f71f9e18452b6"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
