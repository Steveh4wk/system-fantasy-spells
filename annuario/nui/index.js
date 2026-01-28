// Ascolta i messaggi dal client FiveM
window.addEventListener('message', function(event) {
    if (event.data.show == true) {
        if (event.data.pages) {
            let pagePromises = [];
            
            // Processa ogni pagina del libro
            $.each(event.data.pages, function(index, page) {
                const pagePromise = new Promise((resolve) => {
                    let imgSrc;
                    if (page.source === 'local') {
                        // Immagini locali dalla cartella img/
                        imgSrc = 'img/' + page.pageName + '.png?v=' + Math.random();
                        resolve(imgSrc);
                    } else if (page.source === 'discord') {
                        // Recupera l'URL dell'immagine da Discord tramite server
                        $.post(`https://${GetParentResourceName()}/getDiscordImage`, JSON.stringify({
                            channelId: event.data.discordChannelId,
                            messageId: page.pageName
                        }), function(response) {
                            resolve(response);
                        }).fail(function() {
                            // Immagine segnaposto trasparente in caso di errore
                            resolve('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');
                        });
                    } else {
                        // URL web diretti
                        imgSrc = page.pageName;
                        resolve(imgSrc);
                    }
                }).then(imgSrc => {
                    // Aggiunge la pagina al flipbook
                    let pageClass = page.type === 'hard' ? ' class="hard"' : '';
                    let imgStyle = '';
                    
                    // Controlla se è la copertina frontale
                    const isFrontCover = page.pageName.includes('COPERTINA') && !page.pageName.includes('END');
                    // Controlla se è la copertina finale
                    const isBackCover = page.pageName.includes('COPERTINA_END');
                    console.log("Processing page:", page.pageName, "isBackCover:", isBackCover);
                    // Controlla se è una pagina vuota normale (non PAGINA_VUOTA_COPERTINA) o PAGINA_1
                    const isEmptyPage = (page.pageName.includes('PAGINA_VUOTA') && !page.pageName.includes('COPERTINA')) || page.pageName === 'PAGINA_1' || imgSrc.includes('data:image/png;base64,iVBORw0KGgo');
                    
                    if (isFrontCover) {
                        // Per la copertina frontale, aggiungi come pagina hard singola con retro
                        const pageDiv = `<div class="hard" id="front-cover"><img src="${imgSrc}" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}${imgStyle}></div>`;
                        $('#contenitore').append(pageDiv);
                        
                        // Aggiungi il retro della copertina (PAGINA_VUOTA_COPERTINA)
                        const backPageDiv = `<div class="hard" id="front-right-page"><img src="img/PAGINA_VUOTA_COPERTINA.png" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}></div>`;
                        $('#contenitore').append(backPageDiv);
                        
                        // Aggiungi PAGINA_VUOTADX per iniziare la sequenza
                        const rightPageDiv = `<div><img src="img/PAGINA_VUOTADX.png" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}></div>`;
                        $('#contenitore').append(rightPageDiv);
                        
                    } else if (isBackCover) {
                        // Aggiungi COPERTINA_END come pagina hard singola alla fine
                        console.log("Adding COPERTINA_END page");
                        const pageDiv = `<div class="hard" id="final-back-cover"><img src="${imgSrc}" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}${imgStyle}></div>`;
                        $('#contenitore').append(pageDiv);
                        console.log("COPERTINA_END added successfully");
                        
                    } else if (isEmptyPage) {
                        // Controlla se è l'ultima pagina vuota prima della copertina finale
                        const isLastEmptyBeforeBackCover = index === event.data.pages.length - 2 && event.data.pages[index + 1].pageName.includes('COPERTINA_END');
                        
                        // Per le pagine vuote normali, aggiungi PAGINA_VUOTASX a sinistra e PAGINA_VUOTADX a destra
                        if (!isLastEmptyBeforeBackCover) {
                            // Pagina sinistra
                            const leftPageDiv = `<div><img src="img/PAGINA_VUOTASX.png" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}></div>`;
                            $('#contenitore').append(leftPageDiv);
                            
                            // Pagina destra
                            const rightPageDiv = `<div><img src="img/PAGINA_VUOTADX.png" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}></div>`;
                            $('#contenitore').append(rightPageDiv);
                        } else {
                            // Per l'ultima pagina vuota prima della copertina finale, aggiungi PAGINA_VUOTASX e PAGINA_VUOTA_COPERTINA
                            const leftPageDiv = `<div><img src="img/PAGINA_VUOTASX.png" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}></div>`;
                            $('#contenitore').append(leftPageDiv);
                            
                            const rightPageDiv = `<div class="hard" id="final-empty-cover" style="cursor: pointer;"><img src="img/PAGINA_VUOTA_COPERTINA.png" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}></div>`;
                            $('#contenitore').append(rightPageDiv);
                        }
                    } else {
                        // Per le pagine normali (come PAGINA_1), aggiungi come pagina singola
                        const pageDiv = `<div${pageClass}><img src="${imgSrc}" width=${Math.floor(event.data.size.width * 0.7)} height=${Math.floor(event.data.size.height * 1.0)}${imgStyle}></div>`;
                        $('#contenitore').append(pageDiv);
                    }
                    
                    // Mostra testo sulla copertina se è la prima pagina hard
                    if (page.type === 'hard' && page.pageName.includes('copertina_annuario')) {
                        $('#testo-copertina').show();
                    }
                });
                
                pagePromises.push(pagePromise);
            });
            
            // Inizializza il flipbook dopo aver caricato tutte le pagine
            Promise.all(pagePromises).then(() => {
                $('#contenitore').turn({
                    gradients: true,
                    autoCenter: true,
                    width: Math.floor(event.data.size.width * 2 * 0.7), // Ridotto del 10% (da 0.8 a 0.7)
                    height: Math.floor(event.data.size.height * 1.0), // Aumentato del 20% (da 0.8 a 1.0)
                    page: 1,
                    acceleration: true,
                    elevation: 50, // Ombra per effetto 3D
                    when: {
                        turning: function(e, page, view) {
                            // Assicura posizioni consistenti durante il flip
                            $('#contenitore').css('position', 'relative');
                            $('#contenitore').css('left', 'auto');
                        }
                    }
                });
                
                // Personalizza gli angoli di partenza per i flip
                $('#contenitore').turn('options', {
                    turnCorners: 'all' // Abilita tutti i corner per i flip
                });
                $('body').css('display', 'block');
                
                // Debug: verifica le pagine caricate
                console.log("Total pages loaded:", $('#contenitore').turn('pages'));
                console.log("Final back cover exists:", $('#final-back-cover').length > 0);
                console.log("Final empty cover exists:", $('#final-empty-cover').length > 0);
                
                // Verifica il contenuto del contenitore
                console.log("Contenitore HTML:", $('#contenitore').html());
                
                // Aggiungi il gestore di click per la pagina vuota copertina finale
                $(document).on('click', '#final-empty-cover', function() {
                    console.log("Final empty cover clicked!");
                    const totalPages = $('#contenitore').turn('pages');
                    console.log("Total pages:", totalPages);
                    const finalCoverPage = totalPages;
                    console.log("Jumping to page:", finalCoverPage);
                    
                    // Esegui l'hard flip singolo alla copertina finale
                    $('#contenitore').turn('page', finalCoverPage);
                });
                
                // Aggiungi il gestore di click per PAGINA_VUOTA_COPERTINA dopo COPERTINA frontale
                $('#front-right-page').on('click', function() {
                    // Calcola la pagina successiva (dopo PAGINA_VUOTA_COPERTINA + PAGINA_VUOTADX)
                    const currentPage = $('#contenitore').turn('page');
                    const nextPage = currentPage + 2; // Salta le due pagine correnti
                    
                    // Esegui il flip alla pagina successiva
                    $('#contenitore').turn('page', nextPage);
                });
                
                
            });
        }
    } else if (event.data.show == false) {
        // Nasconde l'interfaccia del libro
        $('body').css('display', 'none');
    }

    // Gestisce la chiusura del libro con il tasto ESC
    $(document).keyup(function(e) {
        if (e.keyCode == 27) {
            $('body').css('display', 'none');
            if ($('#contenitore').turn('is')) {
                $('#contenitore').turn('page', 1);
                $('#contenitore').turn('destroy');
            }
            contenitore.style = "";
            $.post(`https://${GetParentResourceName()}/chiudi`, JSON.stringify({}));
        }
    });
});
