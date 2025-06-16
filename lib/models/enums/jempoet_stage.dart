enum JempoetStage {
  idle, // nothing started yet
  informed, // “Kolektoer informed”
  onTheWay, // “Kolektoer is on the way …”
  collected, // item picked up
  sorting, // waiting for ‘pemilahan’
  done, // finished (optional)
}
