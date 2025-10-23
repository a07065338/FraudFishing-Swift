//
//  ScreenCreateReport.swift
//  Fraud Fishing
//
//  Created by Javier Canella Ramos on 23/09/25.
//

import SwiftUI
import PhotosUI

// Vista principal que orquesta el flujo de creación de reportes
struct ScreenCreateReport: View {
    @State var reportedURL: String
    @State private var selectedCategory: CategoryDTO? = nil
    @State private var tags: [String] = []
    @State private var description: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var title: String = ""
    
    @State private var currentPage = 0
    @Environment(\.presentationMode) var presentationMode

    // Controllers
    @StateObject private var controller = CreateReportController()
    @StateObject private var categoriesController = CategoriesController()

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)]),
                               startPoint: UnitPoint(x:0.5, y:0.1),
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Contenido de la página actual
                    TabView(selection: $currentPage) {
                        Step1_URLView(reportedURL: $reportedURL)
                            .tag(0)
                        Step2_ClassificationView(
                            selectedCategory: $selectedCategory,
                            tags: $tags,
                            title: $title,
                            categoriesController: categoriesController
                        )
                            .tag(1)
                        Step3_DescriptionView(
                            description: $description,
                            selectedImage: $selectedImage,
                            selectedImageData: $selectedImageData
                        )
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    // Navegación y botones
                    if currentPage < 2 {
                        // Botón de Siguiente
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(red: 0.0, green: 0.71, blue: 0.737))
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.bottom, 20)
                    } else {
                        // Botón de Enviar Reporte
                        Button(action: {
                            guard let category = selectedCategory else { return }
                            
                            Task {
                                await controller.sendReport(
                                    reportedURL: reportedURL,
                                    categoryId: category.id,
                                    categoryName: category.name,
                                    tags: tags,
                                    description: description,
                                    selectedImageData: selectedImageData
                                )
                            }
                        }) {
                            if controller.isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding()
                            } else {
                                Text("Enviar reporte")
                                    .font(.poppinsBold(size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            (controller.isSending || selectedCategory == nil || description.isEmpty)
                            ? Color.gray
                            : Color.red
                        )
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                        .disabled(controller.isSending || selectedCategory == nil || title.isEmpty || description.isEmpty)
                    }
                    
                    // Indicadores de página personalizados
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .frame(width: index == currentPage ? 20 : 8, height: 8)
                                .foregroundColor(index == currentPage ? Color(red: 0.0, green: 0.71, blue: 0.737) : .white.opacity(0.8))
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if currentPage > 0 {
                            withAnimation {
                                currentPage -= 1
                            }
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(10)
                            .background(Color(red: 0.0, green: 0.71, blue: 0.737))
                            .clipShape(Circle())
                    }.padding(.top, 25)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        // Cargar categorías al aparecer
        .task {
            await categoriesController.fetchCategories()
        }
        // Alerta de error
        .alert("Error al Enviar", isPresented: .constant(controller.reportError != nil), actions: {
            Button("OK") { controller.reportError = nil }
        }, message: {
            Text(controller.reportError?.localizedDescription ?? "Ocurrió un error desconocido.")
        })
        // Alerta de éxito
        .alert("Reporte Enviado", isPresented: $controller.isSuccess) {
            Button("Aceptar") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("¡Gracias! Tu reporte ha sido enviado con éxito.")
        }
    }
}

// --- Vistas para cada paso ---

// Paso 1: Confirmar URL
struct Step1_URLView: View {
    @Binding var reportedURL: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Para comenzar...")
                .font(.poppinsMedium(size: 34))
                .foregroundColor(.white)
                .padding(.horizontal, 30)

            Text("Confirma el URL de la página.")
                .font(.poppinsRegular(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 30)

            StyledTextField(
                label: "URL",
                placeholder: "https://paginafake.com",
                text: $reportedURL,
                iconName: "link"
            )
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding(.top, 35)
    }
}

// Paso 2: Clasificar la amenaza (MODIFICADO)
struct Step2_ClassificationView: View {
    @Binding var selectedCategory: CategoryDTO?
    @Binding var tags: [String]
    @Binding var title: String
    @ObservedObject var categoriesController: CategoriesController
    
    @State private var newTag = ""
    @State private var showLimitMessage = false
    private let maxTags = 5

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 80), spacing: 8)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Clasifica la amenaza")
                .font(.poppinsMedium(size: 34))
                .foregroundColor(.white)
                .padding(.horizontal, 30)

            Text("Escoge una categoría de entre la lista, escribe un título y algunas etiquetas.")
                .font(.poppinsRegular(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 30)

            // Campo de Título
            StyledTextField(
                label: "Título del reporte",
                placeholder: "Ej: Sitio web fraudulento de banco",
                text: $title,
                iconName: "text.alignleft"
            )

            // Selector de Categoría con carga dinámica
            VStack(alignment: .leading, spacing: 8) {
                Text("Categoría")
                    .font(.poppinsSemiBold(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                if categoriesController.isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Cargando categorías...")
                            .font(.poppinsRegular(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.vertical, 8)
                } else if let error = categoriesController.errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error)
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.red)
                        Button("Reintentar") {
                            Task {
                                await categoriesController.fetchCategories(forceRefresh: true)
                            }
                        }
                        .font(.poppinsSemiBold(size: 14))
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                    }
                } else {
                    HStack {
                        Image(systemName: "chevron.down.circle")
                            .foregroundColor(.white.opacity(0.6))
                        
                        Picker("Selecciona Categoría", selection: $selectedCategory) {
                            Text("Selecciona una categoría").tag(nil as CategoryDTO?)
                            ForEach(categoriesController.categories) { category in
                                Text(category.name).tag(category as CategoryDTO?)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(.white.opacity(0.8))
                    }
                    
                    // Mostrar descripción de la categoría seleccionada
                    if let category = selectedCategory {
                        Text(category.description)
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .italic()
                            .padding(.top, 4)
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 30)

            // Campo para añadir etiquetas
            StyledTextField(
                label: "Etiquetas",
                placeholder: "Añade una etiqueta",
                text: $newTag,
                iconName: "tag",
                onCommit: {
                    let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    guard !tags.contains(trimmed) else { newTag = ""; return }

                    if tags.count >= maxTags {
                        showLimitMessage = true
                    } else {
                        tags.append(trimmed)
                        newTag = ""
                        showLimitMessage = false
                    }
                }
            )
            .disabled(tags.count >= maxTags)

            // Mensaje de límite alcanzado
            if showLimitMessage {
                Text("Has alcanzado el límite de 5 etiquetas.")
                    .font(.poppinsRegular(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 30)
            }

            // Chips responsivos
            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 6) {
                        Text(tag)
                            .font(.poppinsRegular(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Button(action: {
                            if let index = tags.firstIndex(of: tag) {
                                tags.remove(at: index)
                                if tags.count < maxTags { showLimitMessage = false }
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }.padding(.top, 35)
    }
}

// Paso 3: Descripción y Evidencia
struct Step3_DescriptionView: View {
    @Binding var description: String
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cuéntanos...")
                .font(.poppinsMedium(size: 34))
                .foregroundColor(.white)
                .padding(.horizontal, 30)

            Text("¿Cuál es el motivo de tu reporte?")
                .font(.poppinsRegular(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 30)

            // Campo de Descripción
            VStack(alignment: .leading, spacing: 8) {
                Text("Descripción")
                    .font(.poppinsSemiBold(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(height: 150)
                    
                    if description.isEmpty {
                        Text("Describe detalladamente el problema que encontraste...")
                            .font(.poppinsRegular(size: 16))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $description)
                        .font(.poppinsRegular(size: 16))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden) // ✅ Esto es crucial - oculta el fondo blanco
                        .background(Color.clear)
                        .frame(height: 150)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 30)

            // Selector de Imagen
            VStack(alignment: .leading, spacing: 8) {
                Text("Imagen")
                    .font(.poppinsSemiBold(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                    VStack {
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 150)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Selecciona Imagen")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                }
                .onChange(of: selectedImage) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }.padding(.top, 35)
    }
}


// --- Componentes Reutilizables ---

struct StyledTextField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var iconName: String
    var onCommit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.poppinsSemiBold(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.6))

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.poppinsRegular(size: 18))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    TextField("", text: $text, onCommit: {
                        onCommit?()
                    })
                        .font(.poppinsRegular(size: 18))
                        .foregroundColor(.white)
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 30)
    }
}


#Preview {
    ScreenCreateReport(reportedURL: "https://ejemplo.com")
}

