export const sortByKills = (players, localPlayer) => {
  return players
    .concat()
    .filter(player => player.socket_id !== localPlayer.socket_id)
    .sort((a, b) => (a.kill_count < b.kill_count ? 1 : -1))
    .slice(0, 4)
    .concat(localPlayer)
    .sort((a, b) => (a.kill_count < b.kill_count ? 1 : -1))
}
