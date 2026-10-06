# Toski para Oh My Zsh

Tema de prompt para o [Oh My Zsh](https://ohmyz.sh) com as cores da Toski Labs.
Inspirado no [Spaceship](https://spaceship-prompt.sh): duas linhas, informação só quando importa
e a patinha da Paçoca no lugar do `❯`.

```
 ~/Docs/toskilabs/web on  main ⇡1 +2 !1 ?3 ·················  took  12s at  14:37:39
🐾
```

Combina com os temas Toski para [iTerm2](https://github.com/Toski-Labs/toski-labs-iterm-theme)
e [VS Code](https://github.com/Toski-Labs/toski-labs-vscode-theme) e usa as cores do
[Toski DS](https://github.com/Toski-Labs/toski-ds).

## Requisitos

- zsh 5.7 ou mais novo e Oh My Zsh
- Uma [Nerd Font](https://www.nerdfonts.com) no terminal, para os ícones
  (sem ela, use `TOSKI_ICONS=false`)
- git 2.35 ou mais novo para mostrar o stash (versões antigas funcionam, sem o stash)

## Instalar

```sh
curl -fsSL https://raw.githubusercontent.com/Toski-Labs/toski-labs-oh-my-zsh/main/toski.zsh-theme \
  -o "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/toski.zsh-theme"
```

No `~/.zshrc`:

```sh
ZSH_THEME="toski"
```

Abra um terminal novo (ou rode `exec zsh`).

## O que aparece

### Linha de cima, à esquerda

| Seção | Quando | Exemplo |
|---|---|---|
| Usuário e máquina | só por SSH ou como root | ` stefany@mac in` |
| Pasta | sempre (ícone de casa no `~`, cadeado se não der para escrever) | ` ~/Docs/toskilabs` |
| Git | dentro de um repositório | `on  main ⇡1 +2 !1 ?3` |
| Node | com `TOSKI_SHOW_NODE=true` e um `package.json`, `.nvmrc` ou `.node-version` na pasta | `via  v22.12.0` |

### Git

| Símbolo | Significado |
|---|---|
| ` main` | branch atual |
| ` v1.0` | tag (HEAD solto numa tag) |
| ` a1b2c3d` | commit solto (detached HEAD) |
| `rebase 2/5`, `merge`, `cherry-pick`, `revert`, `bisect`, `am` | operação em andamento |
| `=1` | arquivos em conflito |
| `⇡1` / `⇣1` | commits à frente / atrás do remoto |
| `+2` | arquivos no stage |
| `»1` | arquivos renomeados |
| `!1` | arquivos modificados |
| `✘1` | arquivos apagados |
| `?3` | arquivos novos, fora do git |
| `$1` | entradas no stash |

O status sai de um único `git status --porcelain=v2`, então o prompt continua rápido.

### Linha de cima, à direita

| Seção | Quando | Exemplo |
|---|---|---|
| Duração | o último comando levou 2 s ou mais | `took  12s` |
| Erro | o último comando terminou com erro | ` 127` |
| Jobs | há processos em segundo plano | ` 1` |
| Hora | sempre | `at  14:37:39` |

Os pontinhos (`···`) ligam os dois lados. Se o terminal ficar estreito demais, o lado
direito some.

### Linha de baixo

A patinha 🐾. Se você trocar por um caractere como `❯`, ele fica caramelo quando o último
comando deu certo e vermelho quando deu erro.

## Cores

| Papel | Escuro | Claro |
|---|---|---|
| Pasta, patinha | `#DB9A5B` caramelo | `#A9541F` ferrugem |
| Branch | `#CDA6D0` | `#7A4E8C` |
| Stage | `#9CC48F` | `#3F6E3B` |
| Modificados, erro | `#F09A78` | `#A3341A` |
| Arquivos novos | `#8CC7BA` | `#2E7468` |
| À frente / atrás | `#8FB8C9` | `#2F6185` |
| Duração, operação | `#E8C26B` | `#8A6A00` |
| Textos de apoio (`on`, `took`, `at`) | `#C2AE98` | `#6B5648` |
| Pontinhos | `#43352B` | `#E6D8C4` |

Com `TOSKI_COLORS=auto` (padrão), o tema usa essas cores exatas quando o terminal tem
truecolor (o iTerm2 tem) e acompanha o modo claro ou escuro do macOS. Nos outros terminais
ele usa as 16 cores ANSI, e o resultado depende da paleta do terminal. Com o
**☯ Toski** do iTerm2 as duas formas ficam com as cores da Toski Labs.

## Opções

Coloque no `~/.zshrc`, **antes** da linha `source $ZSH/oh-my-zsh.sh`.

| Variável | Padrão | O que faz |
|---|---|---|
| `TOSKI_COLORS` | `auto` | `ds` (cores exatas), `ansi` (paleta do terminal) ou `auto` |
| `TOSKI_MODE` | `auto` | `dark`, `light` ou `auto` (segue o macOS); só vale para `ds` |
| `TOSKI_ICONS` | `true` | `false` tira os ícones Nerd Font |
| `TOSKI_PROMPT_CHAR` | `🐾` | caractere da segunda linha (ex.: `❯`) |
| `TOSKI_PROMPT_CHAR_ERROR` | vazio | caractere quando o último comando deu erro (vazio = o mesmo) |
| `TOSKI_ADD_NEWLINE` | `true` | linha em branco antes de cada prompt |
| `TOSKI_FILL_CHAR` | `·` | caractere que liga os dois lados |
| `TOSKI_DIR_TRUNCATE` | `0` | quantas pastas mostrar (`0` = caminho inteiro) |
| `TOSKI_EXEC_TIME_MIN` | `2` | a partir de quantos segundos mostrar a duração |
| `TOSKI_TIME_FORMAT` | `%H:%M:%S` | formato da hora ([strftime](https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html)) |
| `TOSKI_SHOW_TIME` | `true` | mostra a hora |
| `TOSKI_SHOW_EXIT_CODE` | `true` | mostra o código de erro |
| `TOSKI_SHOW_NODE` | `false` | mostra a versão do Node em projetos JavaScript |

Exemplo:

```sh
TOSKI_PROMPT_CHAR="❯"
TOSKI_DIR_TRUNCATE=3
ZSH_THEME="toski"
source $ZSH/oh-my-zsh.sh
```

## Licença

MIT. Veja [LICENSE](LICENSE).
