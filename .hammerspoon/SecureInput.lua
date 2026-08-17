-- Detect macOS "secure input" so it stops masquerading as a broken keybind.
--
-- Password fields turn secure input on, and while it is on macOS blocks EVERY
-- keyboard eventtap system wide. What makes this miserable to debug:
--   * hs.hotkey keeps working (it registers a Carbon hotkey, not a tap)
--   * non-keyboard taps keep working too (see ScrollReverser.lua)
--   * hs.accessibilityState() still reports true
-- So a chord mode still shows its alert, then silently types the second key
-- into whatever app is focused.
--
-- Apps are supposed to release it when the password field loses focus. Slack is
-- a repeat offender: it grabs secure input for its 2FA field and then forgets,
-- breaking every chord mode until you quit it.
--
-- Check by hand with: ioreg -l -w 0 | grep -i secureinput
-- A "kCGSSessionSecureInputPID" other than 0 is the app holding it. The whole
-- field disappears when nothing holds it.
-- To reproduce on purpose: Terminal.app menu -> Secure Keyboard Entry, and keep
-- Terminal frontmost. Terminal only holds secure input while it is the active
-- app and hands it back the moment you click away, which is the well behaved
-- pattern and why an unfocused Terminal breaks nothing. Slack instead held it in
-- the background for two days, which is what made this so hard to spot.

SecureInput = {}

-- Name the app holding secure input, e.g. "Slack (pid 1552)", or nil if free.
-- The grep matters: the bare dump is ~7MB and we only want one line of it.
-- ("ioreg -n Root -d1 -k IOConsoleUsers" would be the targeted query, but it
-- returns nothing on macOS 26.)
local function holder()
  local ok, output = pcall(hs.execute, "ioreg -l -w 0 | grep -i secureinput")
  if not ok or not output then return nil end

  local pid = tonumber(output:match('"kCGSSessionSecureInputPID"=(%-?%d+)'))
  if not pid or pid == 0 then return nil end

  local app = hs.application.applicationForPID(pid)
  return string.format("%s (pid %d)", app and app:name() or "an unknown app", pid)
end

--- Returns true, and says why, when a keyboard eventtap would be born dead.
--- Call this before starting any on demand keyDown tap.
function SecureInput.blocked()
  if not hs.eventtap.isSecureInputEnabled() then return false end

  hs.alert.show("⚠️ Secure input is on\nkeyboard shortcuts are blocked by "
    .. (holder() or "an unknown app")
    .. "\nQuit that app to get them back", 5)
  return true
end
