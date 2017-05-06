module RealWorldServer.CommandLine (parseCommand) where

import           Network.Wai.Handler.Warp
import           Options.Applicative
import           RealWorldServer.Types
import           RealWorldServer.VersionInfo

portP :: Parser Port
portP = option auto
    (long "port"
    <> short 'p'
    <> value 3333
    <> metavar "PORT"
    <> help "Port")

configP :: Parser Config
configP = Config <$> portP

serverCommandP :: Parser Command
serverCommandP = ServerCommand <$> configP

versionCommandP :: Parser Command
versionCommandP = flag' VersionCommand (short 'v' <> long "version" <> help "Show version")

commandP :: Parser Command
commandP = serverCommandP <|> versionCommandP

parseCommand :: IO Command
parseCommand = execParser $ info
    (helper <*> commandP)
    (fullDesc <> progDesc "Run Real World development server" <> header ("Real World development server " ++ fullVersionString))
