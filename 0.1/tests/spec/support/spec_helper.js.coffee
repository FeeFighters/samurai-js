beforeEach ->
  @addMatchers
    toBePlaying: ->
      player = @actual
      player.currentlyPlayingSong == expectedSong and player.isPlaying
