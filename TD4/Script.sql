select par_id, par_prenom , par_nom from public.t_e_participant_par;

select par_id from public.T_J_INSCRIPTION_INS;

-- Q1
SELECT p.PAR_ID, p.PAR_NOM, p.PAR_PRENOM, COUNT(i.INS_ID) AS "Nb inscriptions"
FROM t_e_participant_par p
JOIN public.t_j_inscription_ins i ON p.par_id = i.par_id
GROUP BY  p.par_id , p.par_nom , p.par_prenom
ORDER BY "Nb inscriptions" DESC;

-- Q2
select fi.fil_nom , count(i.ins_id) As "Nb inscription"
From t_r_filiere_fil fi
left join public.t_e_fete_fet f ON fi.fil_id = f.fil_id
left join public.t_j_inscription_ins i ON f.fet_id = i.fet_id
GROUP BY fi.fil_nom
ORDER BY "Nb inscription" DESC;

-- Q3
select p.par_id,p.par_nom,p.par_prenom
from t_e_participant_par p
left join t_j_inscription_ins i on i.par_id = p.par_id
where i.ins_id is null;


-- Q4
select f.fil_nom ,count(e.edf_num) As "nb édition"
from t_r_filiere_fil f
left join public.t_e_fete_fet fe on f.fil_id = fe.fil_id
left join public.t_e_editionfete_edf e on e.fet_id = fe.fet_id
group by f.fil_nom
order by "nb édition" DESC;

-- Q5

select f.fil_nom ,count(e.edf_num) As "nb édition",
    CASE
        WHEN COUNT(e.edf_num) = 0 THEN 'Bougez vous !'
        WHEN COUNT(e.edf_num) BETWEEN 1 AND 2 THEN 'GO (Gentil organisateur)'
        WHEN COUNT(e.edf_num) BETWEEN 3 AND 5 THEN 'SO (Super organisateur)'
        WHEN COUNT(e.edf_num) >= 6 THEN 'Wahou! J''aurais dû être prof/ancien/étudiant dans cette filière'
    END AS "Message"
from t_r_filiere_fil f
left join public.t_e_fete_fet fe on f.fil_id = fe.fil_id
left join public.t_e_editionfete_edf e on e.fet_id = fe.fet_id
group by f.fil_nom
order by "nb édition" DESC;

-- Q6

select p.par_id , p.fil_id ,p.par_nom, p.par_prenom , p.par_sexe , p.par_mail, p.par_mobile , en.ens_numbureau , et.etu_ine, et.etu_datenaiss, et.etu_annee, a.pro_anneepromo, a.anc_entreprise
from t_e_participant_par p
join public.t_j_inscription_ins i on i.par_id = p.par_id
join public.t_e_fete_fet teff on i.fet_id = teff.fet_id
left join public.t_e_enseignant_ens en on en.par_id = p.par_id
left join public.t_e_ancien_anc a on a.par_id = p.par_id
left join public.t_e_etudiant_etu et on p.par_id = et.par_id
left join public.t_r_filiere_fil f on p.fil_id = f.fil_id
where f.fil_nom = 'CGP' AND teff.fet_nom = 'Gala anniversaire 20 ans'

