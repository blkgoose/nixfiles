// The projector's browser exposes the mkv's embedded subtitle stream as a TextTrack and Jellyfin adds its own
// cues (with an explicit `line` from the subtitle offset setting) to that same track, so every line shows twice.
// Remove the cues the platform put there (line === "auto") so only Jellyfin's remain.
(function () {
  function purge(track) {
    if (track.mode === 'disabled' || !track.cues) return;
    var cues = Array.prototype.slice.call(track.cues);
    for (var i = 0; i < cues.length; i++) {
      if (cues[i].line === 'auto') {
        try {
          track.removeCue(cues[i]);
        } catch (e) {}
      }
    }
  }

  function watch(video) {
    if (video._subsFix) return;
    video._subsFix = true;
    var attach = function (track) {
      if (track._subsFix) return;
      track._subsFix = true;
      track.addEventListener('cuechange', function () { purge(track); });
    };
    for (var i = 0; i < video.textTracks.length; i++) attach(video.textTracks[i]);
    video.textTracks.addEventListener('addtrack', function (e) { attach(e.track); });
  }

  setInterval(function () {
    var video = document.querySelector('video');
    if (!video) return;
    watch(video);
    for (var i = 0; i < video.textTracks.length; i++) purge(video.textTracks[i]);
  }, 150);
})();
