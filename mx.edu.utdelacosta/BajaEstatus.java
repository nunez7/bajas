/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package mx.edu.utdelacosta;

/**
 *
 * @author raul_
 */
public class BajaEstatus {
    
    private int cveBajaEstatus;
    private BajaSolicitud cveBajaSolicitud;
    private Persona cvePersona;
    private int situacionBaja;
    private String comentario;
    private String fechaAlta;

    public int getCveBajaEstatus() {
        return cveBajaEstatus;
    }

    public void setCveBajaEstatus(int cveBajaEstatus) {
        this.cveBajaEstatus = cveBajaEstatus;
    }

    public BajaSolicitud getCveBajaSolicitud() {
        return cveBajaSolicitud;
    }

    public void setCveBajaSolicitud(BajaSolicitud cveBajaSolicitud) {
        this.cveBajaSolicitud = cveBajaSolicitud;
    }

    public Persona getCvePersona() {
        return cvePersona;
    }

    public void setCvePersona(Persona cvePersona) {
        this.cvePersona = cvePersona;
    }

    public int getSituacionBaja() {
        return situacionBaja;
    }

    public void setSituacionBaja(int situacionBaja) {
        this.situacionBaja = situacionBaja;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    public String getFechaAlta() {
        return fechaAlta;
    }

    public void setFechaAlta(String fechaAlta) {
        this.fechaAlta = fechaAlta;
    }
    
    
}
