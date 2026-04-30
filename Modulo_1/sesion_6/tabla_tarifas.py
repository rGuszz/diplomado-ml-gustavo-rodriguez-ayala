"""
Esta es una clase utilizada para reprensetar una tabla actuarial de tarificación
"""


class Tablatarifas:

    def __init__(self, edad_inicio, edad_final, brinco, piso):
        """
        Esto inicializa las tarifas basadas en una edad de inicio y finalización.
        Parámetros
        __________
        edad_inicio: Edad de inicial
        edad_final: Edad final
        brinco: Tamaño de los rangos de edad
        piso: Si es que se quiere segmentar con el grupo más pequeño o más grande
        """
        self.edad_inicio = edad_inicio
        self.edad_final = edad_final
        self.brinco = brinco
        self.edades = list(range(edad_inicio, edad_final + 1, brinco)) # Se suma 1 para incuir la edad_final
        self.piso = piso
        self.tarifa = []

    def set_tarifa(self, tarifa):
        """
   	Establecer la tarifa para cada franja de edad
         : param tarifa: una lista de tarifa para la franja de edad
         : return: si la tarifa se estableció o no para la tabla de tarifas
        """
        if len(tarifa) == len(self.edades):
            self.tarifa.extend(tarifa)
            return True
        else:
            return False

    def get_tarifa(self, edad):
        """
	 Obtenga una tarifa única para una edad determinada
         : param edad: la edad de búsqueda
         : return: la tarifa para la edad de búsqueda o 0 si las tarifas no están establecidas para la tabla de tarifas
        """
        edades = self.edades
        piso = self.piso
        tarifa = self.tarifa
        if len(tarifa) == 0:
            return 0
        if edad <= min(edades):
            edad_index = edades.index(min(edades))
        elif edad >= max(edades):
            edad_index = edades.index(max(edades))
        else:
            mayor_que_edad = list(map(lambda x: edad < x, edades))
            edad_index = mayor_que_edad.index(True)
            if piso:
                edad_index = edad_index - 1
        return tarifa[edad_index]

    def __repr__(self):
        edades = self.edades
        tarifa = self.tarifa
        if len(tarifa) > 0:
            table_rows = ['edad {} tiene una tarifa de {}'.format(edad, tarifa) for edad, tarifa in zip(edades, tarifa)]
        else:
            table_rows = ['edad {}'.format(edad) for edad in edades]
        return '\n'.join(table_rows)
