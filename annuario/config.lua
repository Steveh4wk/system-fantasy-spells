-- Configurazione del libro annuario per annuario
Config = {}

-- Configurazione dei libri disponibili
Config.Books = {
    ['annuario'] = {
        ['pages'] = {
            { pageName = "COPERTINA", type = 'hard', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
            { pageName = "COPERTINA_END", type = 'hard', source = 'local' },
        },
        ['prop'] = 'book',
        ['size'] = {
            ['width'] = 720,
            ['height'] = 600,
        },
    },
}

return Config