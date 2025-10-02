-- Imports:
-- =================================================
-- {{{
import XMonad
import Data.Monoid
import Data.Maybe
import System.Exit
import XMonad.Util.NamedScratchpad
import XMonad.Layout.Tabbed
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.Fullscreen
import Graphics.X11.ExtraTypes.XF86
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Layout.Decoration
import XMonad.Layout.Simplest
import XMonad.Util.NamedActions
import XMonad.Util.SpawnOnce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.SubLayouts
import XMonad.Layout.Renamed
import XMonad.Layout.Accordion
import XMonad.Util.Run(spawnPipe, safeSpawn)
import XMonad.Util.ClickableWorkspaces
import System.IO
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier
import XMonad.Actions.MouseResize
import XMonad.Prompt.ConfirmPrompt          -- don't just hard quit
import XMonad.Actions.PerWorkspaceKeys
import XMonad.Actions.WindowGo
import XMonad.Actions.GridSelect



import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns

import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.Magnifier
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))

import XMonad.Layout.ShowWName
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Hooks.WorkspaceHistory
import qualified XMonad.StackSet as W




import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import XMonad.Prompt.FuzzyMatch
import Control.Arrow (first)
import Data.Char (isSpace, toUpper)


import XMonad.Util.EZConfig
import XMonad.Util.Hacks
import XMonad.Actions.Submap
import XMonad.Actions.CopyWindow
import qualified XMonad.StackSet as W
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Tree


-- }}}
-- =================================================
-- Vars:
-- =================================================
-- {{{
myTerminal      = "st"
myBrowser      = "firefox"

promptheight = 20

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myModMask       = mod1Mask
myClickJustFocuses :: Bool
myClickJustFocuses = False
gap = 10
myFont      = "xft:Zekton:size=9:bold:antialias=true"
myBorderWidth :: Dimension
myBorderWidth = 2          

myBackgroundColor = "#282A2E"

myNormalBorderColor :: String
myNormalBorderColor   = "#282A2E" 

myFocusedBorderColor :: String
myFocusedBorderColor  = "#BD7852"  

yellow  = "#b58900"

red     = "#dc322f"

--myWorkspaces    = [" 1 "," 2 "," 3 "," 4 "," 5 "," 6 "," 7 "," 8 "," 9 "]
myWorkspaces            = clickable  $ [" 1 "," 2 "," 3 "," 4 "," 5 "," 6 "," 7 "," 8 "," 9 "]
                                                                              
  where                                                                       
         clickable l = [ "<action=xdotool key alt+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                             (i,ws) <- zip [1..9] l,                                        
                            let n = i ]



-- }}}
-- =================================================
-- Keys:
-- =================================================
-- {{{
myKeys :: [(String, X ())]
myKeys =
  [
   ("M-<Space>", spawn "/home/dadaurs/scripts/dmenu_run_history")
   --("M-<Space>", spawn "dmenu_run")
  ,("M-\\", spawn myBrowser)
  ,("M-d", spawn "clipcat-menu")
  ,("M-q", kill)
  --,("M-S-q", io (exitWith ExitSuccess))
  ,("M-S-<Tab>", sendMessage NextLayout)

  ,("M-S-r", spawn "xmonad --recompile && xmonad --restart")
  ,("M-j", windows W.focusDown)
  ,("M-k", windows W.focusUp)
  ,("M-S-m", windows W.focusMaster)
  ,("M-S-j", windows W.swapDown)
  ,("M-S-k", windows W.swapUp)
  ,("M-h", sendMessage Shrink                                                        )
  ,("M-l", sendMessage Expand)
  ,("M-t",  withFocused $ windows . W.sink)
  ,("M-,", sendMessage (IncMasterN 1))
  ,("M-.", sendMessage (IncMasterN ( -1 )))
  , ("M-f", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) 

  --,("M-s", withFocused toggleFloat)
  , ("M-m", toggleCopyToAll)

  ,("M-C-l", sendMessage $ pullGroup R)
  ,("M-C-h", sendMessage $ pullGroup L)
  ,("M-C-k", sendMessage $ pullGroup U)
  ,("M-C-j", sendMessage $ pullGroup D)
  ,("M-C-u", withFocused (sendMessage . UnMerge))
  ,("M-'", bindOn [("tabs", windows W.focusDown), ("", onGroup W.focusDown')])
  ,("M-;", bindOn [("tabs", windows W.focusUp), ("", onGroup W.focusUp')])


  ,("M-<Tab>", goToSelected $ mygridConfig myColorizer)
  , ("M--", decWindowSpacing 1 <+> decScreenSpacing 1)           -- Decrease window spacing
  , ("M-=", incWindowSpacing 1 <+> incScreenSpacing 1)           -- Increase window spacing

  --,( "<F5>"   , spawn "$HOME/scripts/keybinds/volume.sh down")
  -- ,( "<F6>", spawn "$HOME/scripts/keybinds/volume.sh up")
  --,( "<F3>", spawn "$HOME/scripts/keybinds/volume.sh toggle")
  ,( "<XF86MonBrightnessDown>", spawn "intelbacklight -dec 500")
  ,( "<XF86MonBrightnessUp>", spawn "intelbacklight -inc 500")

  ,("M-`", namedScratchpadAction myScratchPads "terminal")
  ,( "M-S-n", namedScratchpadAction myScratchPads "music")
  ,("M-r h", namedScratchpadAction myScratchPads "htop")
  ,("M-r M-f", namedScratchpadAction myScratchPads "ranger")
  ,("M-p", namedScratchpadAction myScratchPads "pdffiles")

  ,("M-r t", spawn "emacsclient -nc $HOME/Cours/todo.org")
  ,("M-S-p", spawn "urxvt -e fzf_pdffiles /home/dadaurs/Library")
  ,("M-S-f", spawn "st -e ranger")
  ,("M-r e", spawn "emacsclient -nc")
  ,("M-r s", spawn "st -e stig")
  ,("M-r m", spawn "st -e neomutt")
  ,("M-r p", spawn "pavucontrol")
  ,("M-r n", spawn "st -e newsboat")
  ,("M-r b", spawn "st -e bluetoothctl")
  ,("M-r M-p", spawn "st -e python")
  ,("M-r q", spawn "surf /home/dadaurs/Suckless/q.uiver.appx/index.html")
  ,("M-S-c", spawn "~/scripts/charsel")

  ,("M-e e", spawn "~/scripts/lectures/edit-lecture")
  ,("M-e m", spawn "~/scripts/lectures/course-menu")
  ,("M-e n", spawn "~/scripts/lectures/new-lecture")
  ,("M-e c", spawn "~/scripts/lectures/chcourse")
  ,("M-e S-n", spawn "~/scripts/lectures/new-course")
  ,("C-S-c", spawn "$HOME/scripts/curcourses")
  ,("M-r S-f", spawn "/home/dadaurs/scripts/firefox_menu")
  ,("M-r w", spawn "chromium --profile-directory=Default --app-id=hnpfjngllnobngcgfapefoaidbinmjnm")


    , ("M-S-q"                  ,  confirmPrompt hotPromptTheme "Quit XMonad " $ io (exitWith ExitSuccess))

  ]
          where
			toggleCopyToAll = wsContainingCopies >>= \ws -> case ws of
							[] -> windows copyToAll
							_ -> killAllOtherCopies


someKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
      ((modm ,  xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modm              , xK_b     ), sendMessage ToggleStruts)
    ]
   ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
------------------------------------------------------------------------
------------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    ]
-- }}}
-- =================================================
-- Layouts:
-- =================================================
-- {{{
myTabTheme = def {
         fontName = myFont
, activeColor         = myFocusedBorderColor
, inactiveColor       = myNormalBorderColor
, activeBorderColor   = myFocusedBorderColor
, inactiveBorderColor = myNormalBorderColor
, activeTextColor     = "#282c34"
, inactiveTextColor   = "#d0d0d0"
     }


mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True


tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] Simplest
           $ mySpacing 1
           $ limitWindows 12
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] Simplest
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
            $ windowNavigation
            $ addTabs shrinkText myTabTheme
            $ subLayout [] Simplest
            $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] Simplest
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
tabs     = renamed [Replace "tabs"]
           $ tabbed shrinkText myTabTheme


myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats  $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
     where
        nmaster = 1

        ratio   = 1/2

        delta   = 3/100
        myDefaultLayout =  tall
                                 ||| tabs
                                 ||| noBorders monocle
                                 ||| grid
-- }}}
-- =================================================
-- Hooks:
-- =================================================
-- {{{
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
 , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
    ]<+> namedScratchpadManageHook myScratchPads

myEventHook = mempty



myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0


myStartupHook = do
    spawnOnce "xset r rate 300 100 &"
    spawnOnce "source /home/dadaurs/.zshrc &"
    --spawnOnce "xrdb -merge ~/.config/X11/Xresources &"
    spawnOnce "emacs --daemon &"
 --   spawnOnce "mpd &"
    spawnOnce "xrdb -merge /home/dadaurs/.config/X11/Xresources &"
    spawnOnce "emacs --daemon &"
    --spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 " ++ myBackgroundColor ++ " --height 20"

    spawnOnce "clipcatd &"
    spawnOnce "feh --no-fehbg --bg-fill ~/wallpapers/paintings/$(ls /home/dadaurs/wallpapers/paintings/| sort -R | tail -1)& "
    --spawnOnce "blueman-applet &"
    --spawnOnce "nm-applet &"
    spawnOnce "xmodmap ~/.config/xmodmap/capstoctrl  2>&1"
    spawnOnce "xcape "
    --spawnOnce "~/.fehbg &"

-- }}}
-- =================================================
-- Main:
-- =================================================
-- {{{
main :: IO ()
main = do

   xmproc <- spawnPipe "xmobar /home/dadaurs/.config/xmobar/xmobarrc"
   xmonad $ ewmh def{
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        -- numlockMask deprecated in 0.9.1
        -- numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = someKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayoutHook,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook <+> docksEventHook 
      ,  logHook            = myLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput = \x -> hPutStrLn xmproc x  
                        , ppCurrent = xmobarColor "#F0EEF0" "#D7B8FE"  -- Current workspace in xmobar
                        --, ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" ""                -- Visible but not current workspace
                        , ppHidden = xmobarColor "#F0EEF0" "#B3AFC2"    -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#F0EEF0" ""        -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#b3afc2" "" . shorten 60     -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> <fn=2>|</fn> </fc>"          -- Separators in xmobar
                       , ppUrgent = xmobarColor "#C45500" ""  -- Urgent workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        },
        startupHook        = myStartupHook
    } `additionalKeysP` myKeys

-- }}}
-- =================================================
-- Scratchpads:
-- =================================================
-- {{{
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "music" spawnMusic findMusic manageMusic  
                , NS "htop" spawnHtop findHtop manageHtop  
                , NS "ranger" spawnRanger findRanger manageRanger  
                , NS "pdffiles" spawnpdffinder findpdffinder managepdffinder
                ]
  where
    spawnTerm  = myTerminal ++  " -n scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.7
                 w = 0.7
                 t = 0.85 -h
                 l = 0.85 -w
    spawnMusic  = myTerminal ++  "  -n music $HOME/scripts/music"
    findMusic   = resource =? "music"
    manageMusic = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.7
                 w = 0.7
                 t = 0.85 -h
                 l = 0.85 -w
    spawnHtop  = myTerminal ++  " -n htop 'htop'"
    findHtop   = resource =? "htop"
    manageHtop = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.7
                 w = 0.7
                 t = 0.85 -h
                 l = 0.85 -w
    spawnRanger  = myTerminal ++  " -n ranger 'ranger'"
    findRanger   = resource =? "ranger"
    manageRanger = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.7
                 w = 0.7
                 t = 0.85 -h
                 l = 0.85 -w
    spawnpdffinder  = myTerminal ++  " -n pdffiles -e /home/dadaurs/.local/bin/fzf_pdffiles /home/dadaurs/Library"
    findpdffinder  = resource =? "pdffiles"
    managepdffinder = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.7
                 w = 0.7
                 t = 0.85 -h
                 l = 0.85 -w
-- }}}
-- =================================================
-- Prompt:
-- =================================================
-- {{{
myPromptTheme = def
    { font                  = myFont
    , bgColor               = "#282a2e"
    , fgColor               = "#F0EEF0"
    , fgHLight              =  "#282a2e"
    , bgHLight              = "#F0EEF0"
    , borderColor           = "#282a2e"
    , promptBorderWidth     = 0
    , height                = promptheight
    , position              = Top
    }

warmPromptTheme = myPromptTheme
    { bgColor               = yellow
    , fgColor               = "#282a2e"
    , position              = Top
    }

hotPromptTheme = myPromptTheme
    { bgColor               = red
    , fgColor               = "#282a2e"
    , position              = Top
    }
-- }}}
-- =================================================
-- TreeSelect:
-- =================================================
-- {{{
treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "+ Accessories" "Accessory applications" (return ()))
       [ Node (TS.TSNode "Archive Manager" "Tool for archived packages" (spawn "file-roller")) []
       , Node (TS.TSNode "Calculator" "Gui version of qalc" (spawn "qalculate-gtk")) []
       , Node (TS.TSNode "Calibre" "Manages books on my ereader" (spawn "calibre")) []
       , Node (TS.TSNode "Castero" "Terminal podcast client" (spawn (myTerminal ++ " -e castero"))) []
       , Node (TS.TSNode "Picom Toggle on/off" "Compositor for window managers" (spawn "killall picom; picom")) []
       , Node (TS.TSNode "Virt-Manager" "Virtual machine manager" (spawn "virt-manager")) []
       , Node (TS.TSNode "Virtualbox" "Oracle's virtualization program" (spawn "virtualbox")) []
       ]
   ]

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd282c34
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff1c1f24)
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff282c34)
                              , TS.ts_highlight    = (0xffffffff, 0xff755999)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 20
                              , TS.ts_originX      = 100
                              , TS.ts_originY      = 100
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = myTreeNavigation
                              }

myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    , ((0, xK_a),        TS.moveTo ["+ Accessories"])
    , ((0, xK_e),        TS.moveTo ["+ Games"])
    , ((0, xK_g),        TS.moveTo ["+ Graphics"])
    , ((0, xK_i),        TS.moveTo ["+ Internet"])
    , ((0, xK_m),        TS.moveTo ["+ Multimedia"])
    , ((0, xK_o),        TS.moveTo ["+ Office"])
    , ((0, xK_p),        TS.moveTo ["+ Programming"])
    , ((0, xK_s),        TS.moveTo ["+ System"])
    , ((0, xK_b),        TS.moveTo ["+ Bookmarks"])
    , ((0, xK_c),        TS.moveTo ["+ Config Files"])
    , ((0, xK_r),        TS.moveTo ["+ Screenshots"])
    , ((mod4Mask, xK_l), TS.moveTo ["+ Bookmarks", "+ Linux"])
    , ((mod4Mask, xK_e), TS.moveTo ["+ Bookmarks", "+ Emacs"])
    , ((mod4Mask, xK_s), TS.moveTo ["+ Bookmarks", "+ Search and Reference"])
    , ((mod4Mask, xK_p), TS.moveTo ["+ Bookmarks", "+ Programming"])
    , ((mod4Mask, xK_v), TS.moveTo ["+ Bookmarks", "+ Vim"])
    ]
-- }}}
-- =================================================
-- GridSelect:
-- =================================================
-- {{{
-- gridSelect menu layout
myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                (0x28,0x2c,0x34) -- lowest inactive bg
                (0x28,0x2c,0x34) -- highest inactive bg
                (0xc7,0x92,0xea) -- active bg
                (0xc0,0xa7,0x9a) -- inactive fg
                (0x28,0x2c,0x34) -- active fg

mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    --, gs_navigate    = myNavigation
    --, gs_originFractX = 0.5
    --, gs_originFractY = 0.5
    , gs_font         = myFont
    }
-- }}}
-- =================================================
