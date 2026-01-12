# Guía: Cómo Agregar Fotos de Productos en Supabase

## 📋 Resumen
Esta guía te explica cómo configurar y usar la funcionalidad de subida de imágenes de productos en tu aplicación APEG.

## 🔧 Configuración en Supabase (Dashboard)

### Paso 1: Crear el Bucket de Storage

1. Ve a tu proyecto en Supabase Dashboard: https://drqyvhwgnuvrcmwthwwn.supabase.co
2. En el menú lateral, haz clic en **Storage**
3. Haz clic en **New bucket**
4. Configura el bucket:
   - **Name**: `product-images`
   - **Public bucket**: ✅ Activado (para que las imágenes sean públicas)
   - **File size limit**: 5 MB (o el tamaño que prefieras)
   - **Allowed MIME types**: `image/*` (permite todos los tipos de imagen)
5. Haz clic en **Create bucket**

### Paso 2: Ejecutar las Políticas SQL

1. En el menú lateral de Supabase, ve a **SQL Editor**
2. Haz clic en **New query**
3. Copia y pega el contenido del archivo `supabase_permissions.sql`
4. Haz clic en **Run** para ejecutar las políticas
5. Verifica que no haya errores

## 📱 Cómo Funciona en la App

### Flujo de Subida de Imágenes

1. **Usuario selecciona una imagen**:
   - En `AddProductView`, el usuario toca "Seleccionar Imagen"
   - Se abre el selector de fotos del sistema (PhotosPicker)
   - La imagen seleccionada se muestra en un preview

2. **Usuario guarda el producto**:
   - Al tocar "Guardar Producto", primero se sube la imagen a Supabase Storage
   - La imagen se comprime automáticamente a 80% de calidad JPEG
   - Se genera un nombre único usando el UUID del producto
   - Se obtiene la URL pública de la imagen

3. **Se guarda el producto**:
   - Una vez subida la imagen, se guarda el producto en la base de datos
   - La URL de la imagen se incluye en el campo `image_url`

### Archivos Modificados

1. **`Services/StorageService.swift`** (NUEVO):
   - Maneja la subida y eliminación de imágenes
   - Usa URLSession para comunicarse con Supabase Storage
   - Comprime automáticamente las imágenes

2. **`Views/AddProductView.swift`**:
   - Añadido PhotosPicker para seleccionar imágenes
   - Preview de la imagen seleccionada
   - Lógica para subir la imagen antes de guardar el producto

3. **`Utils/SupabaseManager.swift`**:
   - Actualizado `saveProduct()` para aceptar parámetro `imageUrl`

4. **`supabase_permissions.sql`**:
   - Añadidas políticas RLS para Storage
   - Usuarios premium pueden subir/actualizar/eliminar imágenes
   - Todos pueden ver las imágenes (lectura pública)

## 🎯 Permisos y Seguridad

### Políticas Implementadas

- **Lectura (SELECT)**: Pública - Cualquiera puede ver las imágenes
- **Subida (INSERT)**: Solo usuarios premium (`is_premium = true`)
- **Actualización (UPDATE)**: Solo usuarios premium
- **Eliminación (DELETE)**: Solo usuarios premium

### Verificar que un Usuario es Premium

Para hacer que un usuario sea premium, ejecuta en SQL Editor:

```sql
UPDATE public.profiles 
SET is_premium = true 
WHERE id = 'TU_USER_ID_AQUI';
```

Para obtener tu user ID actual, puedes:
1. Ir a **Authentication** > **Users** en Supabase Dashboard
2. Copiar el UUID del usuario

## 🧪 Probar la Funcionalidad

### Checklist de Pruebas

1. ✅ El bucket `product-images` está creado en Storage
2. ✅ Las políticas SQL se ejecutaron sin errores
3. ✅ Tu usuario tiene `is_premium = true`
4. ✅ Puedes abrir la vista "Agregar Producto"
5. ✅ Puedes seleccionar una imagen de tu galería
6. ✅ La imagen se muestra en el preview
7. ✅ Al guardar, la imagen se sube correctamente
8. ✅ El producto se guarda con la URL de la imagen

### Solución de Problemas Comunes

**Error: "No se pudo subir la imagen"**
- Verifica que el bucket `product-images` existe
- Verifica que tu usuario es premium
- Revisa las políticas RLS en Storage

**Error: "Failed to save product"**
- Verifica que la tabla `products` tiene la columna `image_url`
- Verifica que tu usuario tiene permisos para insertar productos

**La imagen no se muestra**
- Verifica que el bucket es público
- Verifica que la URL generada es correcta
- Prueba abrir la URL directamente en el navegador

## 📊 Estructura de URLs

Las imágenes se guardan con este formato de URL:

```
https://drqyvhwgnuvrcmwthwwn.supabase.co/storage/v1/object/public/product-images/[UUID].jpg
```

Ejemplo:
```
https://drqyvhwgnuvrcmwthwwn.supabase.co/storage/v1/object/public/product-images/123e4567-e89b-12d3-a456-426614174000.jpg
```

## 🔄 Próximos Pasos (Opcional)

1. **Optimización de imágenes**:
   - Implementar diferentes tamaños (thumbnail, medium, full)
   - Usar WebP en lugar de JPEG para mejor compresión

2. **Validación**:
   - Validar el tamaño del archivo antes de subir
   - Validar el tipo de archivo (solo imágenes)

3. **UX Mejorada**:
   - Mostrar progreso de subida
   - Permitir editar/recortar la imagen antes de subir
   - Permitir múltiples imágenes por producto

4. **Limpieza**:
   - Eliminar imágenes huérfanas (sin producto asociado)
   - Implementar un sistema de limpieza automática
