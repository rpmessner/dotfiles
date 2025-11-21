# Post-Installation Setup

## Prompt Configuration

The dotfiles repository no longer includes prompt configurations (Powerlevel10k or Starship). This allows each host to maintain its own personalized prompt settings.

### Option 1: Powerlevel10k (Recommended)

Powerlevel10k is already installed via Zinit. To configure it:

```bash
# Run the configuration wizard
p10k configure
```

This will create a `~/.p10k.zsh` file with your personalized settings.

### Option 2: Starship

If you prefer Starship instead:

1. Uncomment the Starship section in `~/.zshrc` (lines 124-125)
2. Comment out the Powerlevel10k line (line 121)
3. Create your config:

```bash
mkdir -p ~/.config/starship
starship preset nerd-font-symbols -o ~/.config/starship/config.toml
```

4. Customize `~/.config/starship/config.toml` as desired

### Prompt Tips

For maximum typing space with Powerlevel10k:
- Use a two-line prompt layout
- Minimize or disable the right prompt
- Consider hiding language version indicators unless needed

## Next Steps

- Restart your terminal or run `source ~/.zshrc`
- Configure your prompt using one of the options above
- Enjoy your new development environment!
