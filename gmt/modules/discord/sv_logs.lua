local webhooks = {
    ['tp-to-player'] = 'https://discord.com/api/webhooks/1261304657872027698/jjtwzPlLZOlz9KA9THZ_KgimxgI84r7Cv02Nofb7JW4H3Y6_Aq8rOl7D-2xU_RUige_R', --sean
    ['sell-chips'] = 'https://discord.com/api/webhooks/1261304917788987524/UiysaPEGvyKD111aflN-8CGXpd_95M8LdFErCSOpnnXjAfBpRepweVgmaRfWHq17dFhf', --sean
    ['cpr'] = 'https://discord.com/api/webhooks/1261305043894669332/AsEZIaYX9R_GLXmZTlQvuzxgnOf1McxEClMpxGrnqDiYPiCjFcL7EVU8YAjioI1rKe9j', --sean
    ['bank-transfer'] = 'https://discord.com/api/webhooks/1261305134298697758/LO4muO6i0IC_lEjzNirNjmbsRXdkTUfc4ygzdfHbiCNhmmvLGKqWoicJM2bXblYPcKJM', --sean
    ['purchase-chips'] = 'https://discord.com/api/webhooks/1261305254419628062/8pQoNzX4168LDEbFXN2OkX7OKQK2BKZQ2P5XgrPkSbOPMcuZEQZn1r4w4xBU1LzEUAOj', --sean
    ['police-k9'] = '', -- for pd dc
    ['seize-boot'] = '', -- for pd dc
    ['pd-panic'] = '', -- for pd dc
    ['screenshot'] = 'https://discord.com/api/webhooks/1261305727050322022/vWtfyYOXUAa1TmD6VI9xmNz0FVpbOT--eLhXRwVmnkDoXXw5Iz1RZdUB-zd6eW9viVYx', --sean
    ['manage-balance'] = '', -- not done
    ['coinflip-bet'] = 'https://discord.com/api/webhooks/1261306138964656239/TZ_oUxT3h_dt8SOJgJKDp4cp57D5QXtYjs_sd01xCZ7uR8wvtHzp91v6nmuJnYOgET2q', --sean
    ['gang'] = 'https://discord.com/api/webhooks/1261306440749158420/fNBmt281K-KWwe7HqXmYSyjrR4Epo4Lm7Q3eKRFm3LkvCldL58a-5NZ8Cdfol3icaIJm', --sean
    ['sell-vehicle'] = 'https://discord.com/api/webhooks/1261306534785454131/mm6uRGySiP3g6HNJ6ZRiXf_mSPHLovPU4yX6Q_4HddMCt67AgIrab8XcN07QS3AYSplB', --sean
    ['pd-clock'] = '', --for pd dc
    ['remove-warning'] = 'https://discord.com/api/webhooks/1261306801060708353/X-jvGHjfJMslV3h-tqBcx0cCkTmGvQaeqGyBlpijgXGFueaHLsWBo731TYEJci9hpmPz', --sean
    ['slash-me'] = 'https://discord.com/api/webhooks/1261306940269527163/MODBtP3XIhU1L5LI4HKcu32XsQOxngwBTith4A3H_7UKh7Hfa0uO683gTTssps7mtjNI', --sean
    ['leave'] = 'https://discord.com/api/webhooks/1261307178984280134/rUdb64ZKN8UlESl6f_h_Kmv6z6yhqYU0btZbthafAiDtuFylabFqQ8QRa_dCAgJObRru', --sean
    ['housing-buy'] = 'https://discord.com/api/webhooks/1261307278238154823/fpt5QqEo3n2seazMZYY5cWy-7BuKCl7K3ax2EXz_DtDJptsW0FYEcbe2rD4huEHhe0Dg', --sean
    ['housing-rob'] = 'https://discord.com/api/webhooks/1261307341962350634/Z04svSpVCU0zOZbBaoNlEM_S5aVfpuOpf6wIFLzECNCxBVhE6goL2uXlQIgZZ5eFK8PA', --sean
    ['housing-rent'] = 'https://discord.com/api/webhooks/1261307424019714048/_KQp_CXwFBSEKHu3IGhaAoF1djUKh55ysThKUQuulcNDV7nOqT12_ffai5KUvIPdeJqW', --sean
    ['fine-player'] = '', --for pd dc
    ['lock-pick'] = 'https://discord.com/api/webhooks/1261307622427201538/IbdeKJknWUdM1IU8YXgLwLhPwVM6KQWVtywi1Cuofeqja6EFiTsuZmbShWq5djrkO6c-', --sean
    ['staff'] = 'https://discord.com/api/webhooks/1261307875528151110/5pXQ7eCd2ZtJtsubChVKSNDdNruTCw0VLFo0uqZwfTm2VXMNSSRv3WBTZzqdmeCMn2he', --sean
    ['blackjack-bet'] = 'https://discord.com/api/webhooks/1261307967412895776/eYzzNkiEjiN8PqycOFgRRObo3rzg1Kd4TdTXRFUXNEVFRlII4Z1twdLlm9IjyIoLLdbH', --sean
    -- ['nhs-clock'] = '',
    ['vehicle'] = 'https://discord.com/api/webhooks/1261308595228774431/q-Xm7VRMHl4tJ-_pINp7x1kt1AZVCiJUYfmz00bUtGv1oNtAdqB073vlfCPZFixHIxX4', --sean
    ['announce'] = 'https://discord.com/api/webhooks/1319677139838177300/2wmST853BUO1lbtlB4lg9431gDim1UpwnNP0TL-4nj-oY46lS6KHEByCdxReYTsh19ln', --sean
    ['give-cash'] = 'https://discord.com/api/webhooks/1322355538889150514/-RiuQ_Nodb4F4NuBLazI8ht14wGF_YqhclA2t6g7YcRAdYcLA-MPaFqU4m7TbQDB0rs7', --sean
    ['tp-player-to-me'] = 'https://discord.com/api/webhooks/1261309094011211827/mupf0ukUOz_PgbFG4S9eBMZ9c9dhR2wY1RGSCaCYne7dZbTF4k1shXLuPx3pcKgLKihM', --sean
    ['search-player'] = 'https://discord.com/api/webhooks/1261309207567667221/HY_EBmj10zgRuvixOaalGqA-04RF2uVu3ARjktkyRzlJw8qJcfy9Qo9sG4fNN5UlqeRh', --sean
    ['sell-to-nearest-player'] = '', -- not done
    ['OOC-logs'] = 'https://discord.com/api/webhooks/1322355649937670186/s2orGzOHTRTZjEEDMZ4glJjXr7zWO--B1YeZxy9fs86q0j9X7YPeiuGV2uXlGqfZ0hpU', --sean
    ['Global-logs'] = 'https://discord.com/api/webhooks/1322355727951466589/j6vMHOuKv9Fr4wzq1xno5KrH8209516HPYC72GJNI8BRH3Wi0xL10v3VSU8BRqN7cuBY', --sean
    ['server-bug'] = 'https://discord.com/api/webhooks/1262902178633486356/Z1zC7JA4odjbyHlravYJgiHIRdQreWYu8zbNoHRO_BcUYbrvlsVTgvuA7fxX3d7ZchHj', 
    ['client-bug'] = 'https://discord.com/api/webhooks/1262475715555758181/D2ynW5AtySiQZj0hWoLjqNaZ0vI4PzVoQUiT_iRt1w-VC1mZFDF2noLnVbnSJiTja-je', 
    ['tp-back-from-admin-zone'] = 'https://discord.com/api/webhooks/1261310413249974362/1EVvRijtPq8BwaWagyc0VR7BMEwSTvi1jtLMDXWIuyifJaXddzuCjb5ZD1g6gGlBiEGw', --sean
    ['kick-player'] = 'https://discord.com/api/webhooks/1322355818540302398/20MyYKmyu7f23FhzYM5oEYaXdngXNvN4ulj8FgqLWxG6dWusgA2YUANE23aPFPw3rQwP', --sean
    ['kit-redeem'] = '', --not done
    ['twitter'] = 'https://discord.com/api/webhooks/1261310710298968135/yhh6q301wXLv-W9ZmWbRDdB6v73qvyPNLRYnIhitSrZAURh11iylPTLryIaLLFX7I2-f', --sean
    ['jail-player'] = '', --not done
    ['rent-vehicle'] = 'https://discord.com/api/webhooks/1261310952524218420/cwWJcZFukxVcX90mIFPHOAjHbokEmxkKTcPsnCNiELFpgulnLtnZ1dwqUTEgcgiqrOui', --sean
    ['group'] = 'https://discord.com/api/webhooks/1319677041448190043/y5ySt6e-89hGvRGGs2uVmnbkpAQ3muZIIVc_sdV4wtfhrcH4v7_k99ubQpAA9G4FwJQa',
    ['tp-to-legion'] = 'https://discord.com/api/webhooks/1261311260545515552/yw7V86_hi2_3mFmxcRsxNF3rSLqPJnN_v3cd211yyAe53pL4ZXkEcmfGu1p4gnULNKgJ', --sean
    ['tp-to-paleto'] = 'https://discord.com/api/webhooks/1261311358943756319/zuEP6I3rhkFYHtftd0LMe-MkctXFbpvxqeEPFLd9Y6C9wHEe-I4b5pJrtFkX-wWZ4vUM', --sean
    ['multiaccounting'] = 'https://discord.com/api/webhooks/1261311448408260609/pZ0zedzvrsS-CO0WhrKuXIUagU34QVplttPjpueg4aVvKFwEiak5zlGbquzr8eRCaNme', --sean
    ['organ-tp'] = 'https://discord.com/api/webhooks/1261311583888347257/58fZLf8-LIiTiQscMSVD2pFko274Py4l1ZpRFgYVPdoVzhB4feqPTg5CTYrxnQIa1ZVO', --sean
    ['feedback'] = 'https://discord.com/api/webhooks/1261311737899253800/pONpDU6ubQieKecm5pK4BEmKLDu30rm5ZcaJl6Yv-snmHV5fLkBcLS-AOm_eC-5z-KR2', --sean
    ['housing-sell'] = 'https://discord.com/api/webhooks/1261311848385347605/slL2TGrhfs7eSh-jokCOZsXmiLgvDloE0ZZ3dLfMZC5vlHAwvKrmQYlJF5kEPJ6s5Nmr', --sean
    ['adminticket-logs'] = 'https://discord.com/api/webhooks/1261312145237475483/uRYnSWzyULk4_DNTZBxrI3TSiPKEC_uNfWvV62KAuE81pI66CqEVR6kMOTw6_I2wBobN', --sean
    ['server-restart'] = 'https://discord.com/api/webhooks/1261312240796041328/NsjifPhfOUwq-KoHGKk_l7qI-qg85wsEhUQFSKDtOLhLKUamZwKjV6iEkW7LHfZ6RrrN', --sean
    ['anon'] = 'https://discord.com/api/webhooks/1261312313487786004/31EuzNmvrlJAQ4aQZ0Z28muUM-vpr8A714xVLBh9ym2dA335BxpUc3jVYM21xJz31aby', --sean
    ['join-leave'] = 'https://discord.com/api/webhooks/1322234739134042163/7e4ScSEXIWZLvL61br2Va8uIll78m4hth8xLB3UAOzk1GqedD92Ak_QEcwmweCGfaOpA', --sean
    ['damage-logs'] = 'https://discord.com/api/webhooks/1261313859231289385/80xowCSEjrRrcZhDuZA4by1gZfD2QFMwnSSxmDzQvqR0tsnWP815zB_mtaev8U3bdK9h', --sean
    ['weapon-logs'] = 'https://discord.com/api/webhooks/1261313934875431132/21NwVLG2o99jAz2Jg_XvPo41cRhyagxdCLRQc4sPitnQloWehYXJ_aQB11LPFokjc-Jx', --sean
    -- ['nhs-afk'] = 'https:///apia1190921751442501705/g_D3QcLoMuFioGBHcxzwifbL9KOvNGJdMKDmKJvB9qQuOmpePns6-5vufXAJzvy1zmlP',
    ['force-clock-off'] = 'https://discord.com/api/webhooks/1321665409342242816/1BesJg3_uWXt7HE5yAwQ3sMkimU91jQZHwqLBjTwqNDpq1jMbAtg_zOTEwHExKLnjQPt', --sean
    ['impound'] = '', --not done
    ['ask-id'] = 'https://discord.com/api/webhooks/1261314169311985685/lQqd6YhqNznQ29TBM3tvB-LRn41HWSLD79LbP3G5oXkpN8iRd7D_-7Zfd8NxsP8o_8XE', --ssean
    ['revive'] = 'https://discord.com/api/webhooks/1319677640566767637/e-HpkYCQpHPt_FRdwaMGXi0zXpe2cAiXv1bzXYL2itglVDY7TNXZKA9uGbHCGHFIHNSB', --sean
    ['media-cache'] = 'https://discord.com/api/webhooks/1321665524035227698/YDkiB8sJdDXNcLaezkcO8IFwxnQ-S9XksBXpEgFpGwUOZ5tqX1zk79ccrbqn8qcjPlOH', --sean
    ['trigger-bot'] = 'https://discord.com/api/webhooks/1321665674271129610/qBR9UQihh1UdeA_mhNuskKhB0VtrThmvQZWkLCpDod91rbdZrHkWYXUo7QxRW_hS5OMa', --sean
    ['unban-player'] = 'https://discord.com/api/webhooks/1322355927818571907/HEEUl48ADupKEv2xy8-r9TXIuK5QviZU1GDuLjI-qL50nzXUn0EGsd6GN4lksyiVUdtk', --sean
    ['purchases'] = 'https://discord.com/api/webhooks/1261314819739488276/1doHMzLRsoHDOfzfNFPOJ8e8ZDfCx0uGFL4JeZ4aGXZneKM_Jud9qylcnxKwRfqwxP6F', --sean
    ['add-car'] = 'https://discord.com/api/webhooks/1321665854672470117/2AsFt3aEkwYLHIrQkITJ_vBIFlNqFWGVisM_pKWNj5K4X7p_mvxMzKNiNZak99WZsXru', --sean
    ['tutorial'] = 'https://discord.com/api/webhooks/1261735266834579509/HJpkLxyV8OdgT3iKh-gH61MFgm38SM3r91Y0WIlEK5oKPJVwsLsCNKeS-Lx80U7Bpaz-', --sean
    ['ban-player'] = 'https://discord.com/api/webhooks/1322356017270358066/K1ix0V8OVx4Yki2YLBPrws4MIOtM1wkNJJ3tftmVjtBbocEZHyFJ5IC68shy9aPgnu3p', --sean
    -- ['nhs-panic'] = 'https:///apia1190923851249483817/_i3Bww1yV8uD9-XtY9AE6q5DUj6XgPvYh2CWBsjbH_1DMiBO8fD_4mo0R1GSjtg4ravj',
    ['tp-to-admin-zone'] = 'https://discord.com/api/webhooks/1321666023383896064/aSr12jKJQGuzyN_8NLBK_ajSnb0EziyzmoDqtAnB8UmzjGc-ZH8bxS5TwO_o-hJm8ZVY', --sean
    ['ban-evaders'] = 'https://discord.com/api/webhooks/1261315579940180040/C5wMfl-pMI2U9LXMisxD8x3fLHMJDYKNrf6WXxPC0X6EKNtAsXOFHmjTB2UscapQ6chr', --sean
    ['spectate'] = 'https://discord.com/api/webhooks/1321547507414728724/TgdXzX2mVm9-IDh5ARfnpyHku_1ublC2L05W60iogtPiOqmf1jrDDNLQ8sqFsj-Dvmzx', --sean
    -- ['hmp-transport'] = 'https:///apia1190924757563101227/Poy4e7vbA7DN7G6F4S915r3msAkZ7Sh4xLDHg3luw20Tkl3pV5JrF_JK4d-Q6Ds4n5Y9',
    ['video'] = 'https://discord.com/api/webhooks/1321666140723740682/duk9JWnPk9JkG-R8jzacvBBj2fXWX2ODJL7VUte3zBYTeUgQ7PuZ0DxSZlMKfBTdSBmJ', --sean
    ['anticheat'] = 'https://discord.com/api/webhooks/1321666222340702269/RmYabRAJf2hJwsIQGxpUN5igw1FBbowMCZ76_YoayNToXPshLSW796clfxp-3qR-l8Bi', --sean
    ['freeze'] = 'https://discord.com/api/webhooks/1321666308504551488/62T0IEMKLir-BANyt-baHiRNKrd_JMacH9eeEHreK-j6ScJvlqDo2yJ31ne6HUjXs58w', --sean
    ['filtered-message'] = 'https://discord.com/api/webhooks/1261316096657723483/ESqYNcOw-EHRIxhVbvbyXfKkyo3fTc7k5Uh651p7kWWu7X6anF9GTkBIZxwqHhgviXjY', --sean
    ['cleanup'] = 'https://discord.com/api/webhooks/1261316167113379841/Y9ZwQ1HdptBX_hS-AMLmNyW7_vCxn9wCR9v6wi0A1v34ewm0S15_EME6ltYlzzAJxRi7', --sean
    ['pd-armoury'] = '', -- for pd dc
    ['staff-mode'] = 'https://discord.com/api/webhooks/1321666396811300866/0L8rU3FaCew_MtHa75M8_cOocs6EbjJnUXeiZFOQGJbzk7yd3abFUPL8FA5L-kThZU3N', --sean
    ['unstuck-logs'] = 'https://discord.com/api/webhooks/1261316669113110599/tHpoklaexE-Kl14-JFzjp-lXSqw8A4eyzEv4fqTzLWiErzNgPlMQTH5uE3UslF6siHur', --sean
    ['com-pot'] = 'https://discord.com/api/webhooks/1321666612926877749/L-KZJOwTlou4O_aN7T7RXawqIFnzRaH2Pmu8wRrMPrNhQ8NEnapTEf_-HnqXN4yipBCx', --sean
    ['no-clip'] = 'https://discord.com/api/webhooks/1261316809546666108/rqFYhHKThYxGmLcE04s8dSpU_sct0CW_3JtDbdFI6Bv4mUHF9tzLjehZgLUP68WafR8M', --sean
    ['pd-afk'] = '', --for pd dc
    ['donation'] = '', --not done
    ['slap'] = 'https://discord.com/api/webhooks/1321666705205760100/zL10g1ctcjsfUb-8_OtXVQu8MGuwSmRF6CHI6W9iUq27am7nyoQx5NYpBIN6g151QGon', --sean
    ['crush-vehicle'] = 'https://discord.com/api/webhooks/1261317326150828054/yhVL5NoJ4_mWeQ5t3cPXwCTAA9xbCR6pOmoKlKYs8-FTyvRe1HzxIKDqO7WgqqZ9sgcI', --sean
    ['killfeed-logs'] = 'https://discord.com/api/webhooks/1321543405959905301/S2suKfHcV5io0DVDFZm38OR29cdpjtP2jIp7zooBgAmK2xETbicU5Ylk-VMdrKhEOoJr', --sean
    ['kills'] = 'https://discord.com/api/webhooks/1319677497490800814/eKreyb6SSA1AeCQ3fE_PiUyFOeaqXJU4dthqi_yEhAwvISpUKeXT7vPydPC4iSIDNsO_', --sean
    ['purchase-highrollers'] = 'https://discord.com/api/webhooks/1261317596020609045/xbFnbFN3AjntXNFWwySzP8pfb2-DMSB7A7ANykEVm0-mNedp0wrp1qq0M8v_C1wxURv1', --sean
    ['warning'] = 'https://discord.com/api/webhooks/1261317750207414426/fsoIjioTMBdxRgYwlXkf2eZu99c2X71eHrkjmMMoOjmg56xopCfYMjeTlYXZUUcDXrID', --sean
    ['car-report'] = '', --not done
    ['headshot'] = 'https://discord.com/api/webhooks/1322356132357996615/vDwM-KRwU35XSDj3J3D91NSDqyEv7RMUyhSRf8GoyDQzDQP3jRJ_0MHfM4N92mNT2QNT', --sean
    ['errors'] = '', --not done
    ['compensation-request'] = 'https://discord.com/api/webhooks/1261318170203918407/OLl4o3L-VRNWO00yNmKesb3zfjvfd3JTjN_6AAPjZTHRsIx9K1d-3AODaDQNEcqswY66', --sean
    ['car-dev'] = '', --not done
    ['paycheck'] = 'https://discord.com/api/webhooks/1261318554792235111/vqdlsauFYpm92xmNUJdcLld-OIiEsJdzfqukb5XRTOpHmH2L8zdbiJZkZtkkZ5KMWAPw', --sean
    ['hidden-state'] = 'https://discord.com/api/webhooks/1261318660950327346/RVm7IqAI42EvfSEEew8Nel4bvOqaddmD0LUTKiYCMB3VHbGJ2DDQbvN8qp0I_ZI02G9n', --sean
    ['discord-reverify'] = 'https://discord.com/api/webhooks/1261318737886318614/OzswSPjQLVz0ebmC8cX5MHBN0SfJWsCDwSUn4NsIzb_aE7xreyBz6q2erifwBTxhms20', --sean
    ['staff-dm'] = 'https://discord.com/api/webhooks/1261318804278083664/byaJ0HAqsdOkUkcFjmt20_vWEjFDcfV6uQlZyT37zUTfEcOsPAmJUNj87j6p9wJczz8N', --sean
    ['gang-info'] = 'https://discord.com/api/webhooks/1261318900361203763/yUARyC2RL6yu91CFdhkt1B_6_eKRHNaRP9tGMbWXWi6x6Pn2Dz-5nvsASNRoA-e8Go4D', --sean
    ['spawn-vehicle'] = 'https://discord.com/api/webhooks/1261319071056531608/S_4x9BmgqKISELH3rHTkkHZuYs_PED92GaZKdXE898FH66VzSmxsrtjLSB6AYtUR2tXk', --sean
    ['lootbag'] = 'https://discord.com/api/webhooks/1261319145757216818/HHjYqhY7rszWV8OjjyZ7u5j0JtPF_bWxzc6sk-NIlQ0RT-U7dQz1oe92qraXEbb0hou3', --sean
    ['new-users'] = '',
    ['be-like-this'] = '',
    ['event-logs'] = 'https://discord.com/api/webhooks/1261738012086374483/T0FDVyR5oIFzgwzqpHzwu9ovsS5frZo9Pzk6-Jv9AKXeVQttju2LEpKUaRCguAGroYhF',
    ['dont-be-like-this'] = '',
    ['spawn-weapon'] = 'https://discord.com/api/webhooks/1322356342865788970/uh7E-wJDfovVy3BlW5VcF_AwSXRHmohCMtgJxg1DkQv6m8wYyuAhUgyWItnuImWCRw9W', --sean
    ['checkdevices'] = 'https://discord.com/api/webhooks/1261738275761291265/WgwQdwX4WIOuEuNkNX2xWINAhho0L9RgNRB4WGwg-QNoJTRn9aMSoUfcMegQabTepp8i',
    -- ['beams'] = 'https:///apia1247559346632659076/Ic8g4K_IsJojhzJZ7iqXcG_D7tAV12Is5hPwoXDS-4LlWE3ZuqJ-9DyJo2Um8Sa_Yafd',

}

local webhookQueue = {}
Citizen.CreateThread(function()
    while true do
        if next(webhookQueue) then
            for k,v in pairs(webhookQueue) do
                Citizen.Wait(100)
                if webhooks[v.webhook] then
                    PerformHttpRequest(webhooks[v.webhook], function(err, text, headers) 
                    end, "POST", json.encode({username = "GMT Logs", avatar_url = 'https://imgur.com/a/xmYNJG7', embeds = {
                        {
                            ["color"] = 0x00328E,
                            ["title"] = v.name,
                            ["description"] = v.message,
                            ["image"] = {
                                ["url"] = v.image,
                            },
                            ["footer"] = {
                                ["text"] = "GMT - "..v.time,
                                ["icon_url"] = "",
                            }
                    }
                    }}), { ["Content-Type"] = "application/json" })
                end
                webhookQueue[k] = nil
            end
        end
        Citizen.Wait(0)
    end
end)
local webhookID = 1
function GMT.sendDCLog(webhook, name, message, image)
    webhookID = webhookID + 1
    webhookQueue[webhookID] = {webhook = webhook, name = name, message = message, image = image or "", time = os.date("%c")}
    local file, err = io.open("C:\\FXServer\\resources\\[GMT]\\[GMT]\\gmt\\logs\\" .. webhook .. ".txt", "a")
    if file then
        file:write("Webhook: " .. webhook .. ", Name: " .. name .. ", Message: " .. message .. ", Image: " .. (image or "") .. ", Time: " .. os.date("%c") .. "\n")
        file:close()
    else
       -- print("Failed to open file: " .. err)
    end
end

function GMT.getWebhook(webhook)
    if webhooks[webhook] then
        return webhooks[webhook]
    end
end

RegisterServerEvent("GMT:sendWebhookClient")
AddEventHandler("GMT:sendWebhookClient", function(webhook, name, message)
    GMT.sendDCLog(webhook, name, message)
end)

RegisterServerEvent("GMT:logVehicleSpawn")
AddEventHandler("GMT:logVehicleSpawn", function(spawncode, thingy)
    local source = source
    local user_id = GMT.getUserId(source)
    if user_id then
        GMT.sendDCLog("vehicle", "GMT Spawn ".. thingy .." Logs", "> Vehicle Spawncode: " .. spawncode .. " \n> Player Name: " .. GMT.getPlayerName(user_id) .. " \n> Players TempID: " .. source .. " \n> Players PermID: " .. user_id)
    end
end)