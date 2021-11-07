//Agencia de mensajería - común a todos los integrantes:
//La agencia elige quién de las mensajeras envía cierto mensaje, según:
// - puede enviar el mensaje.
// - tiene el costo más bajo para ese mensaje.

object agencia {
	
	const mensajeros = #{chasqui, sherpa, messich, pali}
	
	method obtenerMensajerosQuePuedenEnviar(mensaje) = mensajeros.filter {mensajero => mensajero.puedeEnviarMensaje(mensaje)}
	method quienEnvia(mensaje) {
		const mensajerosPosibles = self.obtenerMensajerosQuePuedenEnviar(mensaje)
		return mensajerosPosibles.min { mensajero => mensajero.costoMensaje(mensaje) }
	} 
	
}


// ---------------------------------------------------------------------------------------------
//                                 SEGUNDA           ENTREGA
// ---------------------------------------------------------------------------------------------

object valorRandom {
	
	method generar(a,b) = new Range(start = a, end = b).anyOne()
}

class Sector{
	var property multiploCosto = 15
}


const sectorDeEnviosEstandares = new Sector()
const sectorDeEnviosRapidos = new Sector(multiploCosto = 20)
const sectorDeEnviosVIP = new Sector (multiploCosto = 30) 



class Mensajero{
	
	var property sector = sectorDeEnviosEstandares
	
	const largoMinimoAceptado = 20
	
	method mensajeMayorALargoMinimo(mensaje) =  mensaje.size() > largoMinimoAceptado
	
	method cumpleCondicionParticularDelMensajero(mensaje) = true 
	
	method puedeEnviarMensaje(mensaje) = self.mensajeMayorALargoMinimo(mensaje) && self.cumpleCondicionParticularDelMensajero(mensaje)
	
	method costoMensaje(mensaje) = mensaje.words().size() * sector.multiploCosto()
	
	method enviarMensaje(textoDelmensaje) = new Mensaje(mensaje = textoDelmensaje)
	
}

// ---------- Instancias de la clase Mensajero --------------------------------------------------------

const mensajeroEstandar = new Mensajero(sector = sectorDeEnviosEstandares)
const mensajeroRapido = new Mensajero(sector = sectorDeEnviosRapidos)
const mensajeroVIP = new Mensajero (sector = sectorDeEnviosVIP)

//------------------------------------------------------------------------------------------------------

object chasqui inherits Mensajero {
 
	override method cumpleCondicionParticularDelMensajero(mensaje) = mensaje.size() < 50 
 
	override method costoMensaje(mensaje) = mensaje.size() * 2
	
 }

//------------------------------------------------------------------------------------------------------

object sherpa inherits Mensajero {
 
	var property costoSherpa = 60
 
	override method cumpleCondicionParticularDelMensajero(mensaje) = mensaje.size().even()
	
	override method costoMensaje(mensaje) = self.costoSherpa()
}

//------------------------------------------------------------------------------------------------------

object messich inherits Mensajero {
 
	var property costoPalabra = 10
 
	override method cumpleCondicionParticularDelMensajero(mensaje) = !mensaje.startsWith("a")
 
	override method costoMensaje(mensaje) = mensaje.words().size() * costoPalabra
 }

//------------------------------------------------------------------------------------------------------

object pali inherits Mensajero {
 
	method esPalindromo(mensaje) = mensaje.reverse() == mensaje && mensaje.size() > 20
	
	override method cumpleCondicionParticularDelMensajero(mensaje) = self.esPalindromo(mensaje.replace(" ", "").toUpperCase())
	
	override method costoMensaje(mensaje) = (mensaje.size() * 4).min(80)

}

//------------------------------------------------------------------------------------------------------

object pichca inherits Mensajero  {
	
	override method cumpleCondicionParticularDelMensajero(mensaje) = mensaje.words().size() > 3 
	
	override method costoMensaje(mensaje) = mensaje.size() * valorRandom.generar(3,7)
}



object mensajeroParanoico inherits Mensajero {

	 override method enviarMensaje(textoDelMensaje) = new MensajeCifrado(mensaje = textoDelMensaje)
	
}

object mensajeroAlegre inherits Mensajero {
	
	var property gradoDeAlegria = 0

	method calculoDeDuracionMsj() {
 		if (self.gradoDeAlegria().even())
 			return  6 * gradoDeAlegria
		else return 500
 	}

 	method eleccionTipoDeMsj() { 		
 		if (self.gradoDeAlegria() > 10) 
 			return 4 //{override method enviarMensaje(textoDelMensaje) = new MensajeCantado(mensaje = textoDelMensaje)}
 		else  return 5 //{method enviarMensaje(textoDelMensaje) = new Mensaje(mensaje = textoDelMensaje)} 
	
}

// //los serios envían los 3 primeros mensajes como elocuentes y después envían mensajes cifrados. Es decir 
////que al recibir el primer mensaje, será elocuente, el segundo y el tercero también y a partir del cuarto 
////será cifrado.
////
//
//object serios {
//	
//	method manejoDeMsjSerios() {
//		if (mensajes.take(3)) return self.enviarMsjElocuente(mensajeAEnviar,mensajeroElegido)
//		else return self.enviarMsjCifrado(mensajeAEnviar,mensajeroElegido)
//	}
//}

object mensajeroSerio inherits Mensajero {
	
	//var contadorMensajes = 0
	
	//method incrementarContador() = if (enviarMensaje()) return contadorMensaje + 1
	
}



//        Empresa  de  Mensajería       // -----------------------------------------------------


/*
 Recibir mensaje - Integrante 3 - Modelar el proceso de recibir un mensaje:
  -   verificar que el mensaje no esté vacío (si vacío => la operación no puede realizarse)
  -   elegir mensajero en base a lo desarrollado en la entrega 1.
  -   si ninguna persona puede enviar el mensaje => la operación no puede realizarse.
  -   si todo está ok, el mensaje enviado se debe registrar en el historial , junto con demás 
      datos en base a los requerimientos que siguen
*/


class EntradaDeHistorial {
	var mensajeEnviado
	var mensajero
	var fecha
	method obtenerGananciaDeMensaje(){
		if(mensajeEnviado.size() < 30)return 500 - mensajero.costoMensaje(mensajeEnviado)
		else return 900 - mensajero.costoMensaje(mensajeEnviado)
	}
	
	method mensajeEnviado() = mensajeEnviado 
	method mensajero() = mensajero
	method fecha() = fecha
}

const hoy = new Date()

class UserException inherits Exception {}

object empresaDeMensajeria {
	
	const agenciaDeEnvio = agencia
	var historial = []
	
	method historial() = historial
	
	method recibirMensaje(mensaje){
		if (mensaje.isEmpty()){
			throw new UserException(message = "No se puede recibir un mensaje vacío.")
		}
		if (agenciaDeEnvio.obtenerMensajerosQuePuedenEnviar(mensaje).isEmpty()){
			throw new UserException(message = "Ningún mensajero de los disponibles puede enviar el mensaje.")
		}
		historial.add(new EntradaDeHistorial(mensajeEnviado = mensaje, mensajero = agenciaDeEnvio.quienEnvia(mensaje), fecha = new Date()))
	}
	
	method filtrarHistorialDelMes() = historial.filter{ entrada => entrada.fecha() >= hoy.minusDays(30)}
	

	// Ganancia neta del mes - Común:
	// - considerando los últimos 30 días, teniendo en cuenta el historial de mensajes y lo pagado a los 
	//mensajeros 
	// - costo de los mensajes:
	//    -   500 por mensaje menor a 30 caracteres
	//    -   900 por mensaje mayor o igual a 30 caracteres


	method obtenerGananciaNetaDelMes() = return self.filtrarHistorialDelMes().sum{ entrada => entrada.obtenerGananciaDeMensaje()}


	// Chasqui quilla - Común:
	// Queremos conocer al emplead@ del mes segun:
	// - la persona que más mensajes envió en los últimos 30 días (usando el historial de mensajes) 
	// Notas: 
	//  -en caso de empate devolver cualquiera.
	//  -evitar lógica duplicada entre la ganancia neta y emplead@ del mes.


	method obtenerEmpleadoDelMes(){
		const historialFiltrado = self.filtrarHistorialDelMes()
		const mensajerosQueEnviaron = historialFiltrado.map{entrada => entrada.mensajero()}
		return mensajerosQueEnviaron.max{mensajero => mensajerosQueEnviaron.occurrencesOf(mensajero)}
	}
}

// ---------------------------------------------------------------------------------------------
//                                 TERCERA           ENTREGA
// ---------------------------------------------------------------------------------------------

//Mensajes cantados - integrante 1
//Queremos incorporar un mensaje cantado, que tiene una duración en segundos. la ganancia es la ganancia 
//original del mensaje (500 para un mensaje de menos de 30 caracteres o 900 en caso contrario) 
//tiene un costo de 10%

class Mensaje{
	var property mensaje
 
 	method obtenerGananciaDeMensaje(mensajero){
		if(self.mensaje().size() < 30)return 500 - mensajero.costoMensaje(self.mensaje())
		else return 900 - mensajero.costoMensaje(self.mensaje())
		}
	
 	method separarString() = mensaje.split (' ')
	
	method cantLetrasPorPalabra() =  self.separarString().map {palabras => palabras.size()}
 	
 	method cantPalabrasDeDosLetras() {
		if (self.cantLetrasPorPalabra().contains(2) || self.cantLetrasPorPalabra().contains(2))
		return self.cantLetrasPorPalabra().count{palabras => (palabras == 2 || palabras == 1)}
		else return 0
	}
 	
 	method cifrarMsj() = mensaje.reverse()
	
	method posicionLetra(letra) {	
		if (mensaje.contains(letra) == not true){
			return 0
		}
		else return mensaje.indexOf(letra)
	}
}

class MsjCantado inherits Mensaje {
	var property duracion = 0
 
	method costoMensaje(mensajero) = self.obtenerGananciaDeMensaje(mensajero) + (self.obtenerGananciaDeMensaje(mensajero) * 0.1)
}


// Mensajes cantados - integrante 1
// Los mensajes cantados tienen una duración en segundos. 
// Ganancia = es la establecida anteriormente (500 para mensajes de < 30 caracteres o 900 en caso contrario) 
// Costo = 10%



class MensajeCantado inherits Mensaje {
	
	var property duracion = 0
	method costoMensaje(mensajero) =   self.obtenerGananciaDeMensaje(mensajero) * 0.1
} 


//Mensajes elocuentes - Integrante 2
//El mensaje elocuente
//tiene un grado de elocuencia que se calcula como 1 + la cantidad de palabras del mensaje que tienen 1 ó 2 letras. 


class MensajeElocuente inherits Mensaje {

	const property gradoElocuencia = 0

	method gradoDeElocuencia() = 1 + self.cantPalabrasDeDosLetras()
	
	method costoMensaje(mensajero) = self.gradoDeElocuencia() * self.obtenerGananciaDeMensaje(mensajero)
}

//Mensajes cifrados (Integrante 3)
//El mensaje cifrado
//entrega el mensaje al revés del original. Esto significa que si enviás “no me la container” te devuelve 
//"reniatnoc al em on" el costo es igual al costo original del mensaje al que sumamos un valor, que se 
//calcula como 3 * la primera ocurrencia de la letra ‘a’ en el mensaje. Ejemplo: si mandás “no me la 
//container” debería darte 21 (3 * 7 que es la primera ocurrencia de la “a” en el mensaje), para el mensaje 
//“nosotros no somos como los Orozco” el cálculo da 0, para “abracadabra”  también da 0 (la primera posición 
//de la “a” es 0 ), y para “banana” da 3 * 1 = 3.

//Nota: evitar lógica duplicada en cada definición de mensaje.

class MensajeCifrado inherits Mensaje {
	
	override method mensaje(texto) {
		return texto.reverse()
	}
	
	method calculoCostoCifrado() = 3 * self.posicionLetra('a')
	
	method costoMensaje(mensajero) = mensajero.costoMensaje(mensaje) +  self.calculoCostoCifrado()	
}

	

